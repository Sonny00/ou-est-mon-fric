// backend/src/tabs/tabs.service.ts

import { Injectable, NotFoundException, BadRequestException, ForbiddenException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TabEntity, TabStatus } from './entities/tab.entity';
import { TabSyncRequestEntity, SyncRequestType, SyncRequestStatus } from './entities/tab-sync-request.entity';
import { FriendEntity, FriendStatus } from '../friends/entities/friend.entity'; // ⭐ AJOUTER FriendStatus
import { User } from '../users/entities/user.entity';
import { CreateTabDto } from './dto/create-tab.dto';
import { UpdateTabDto } from './dto/update-tab.dto';
import { NotificationsGateway } from '../notifications/notifications.gateway';

@Injectable()
export class TabsService {
  constructor(
    @InjectRepository(TabEntity)
    private readonly tabRepository: Repository<TabEntity>,
    @InjectRepository(TabSyncRequestEntity)
    private readonly syncRequestRepository: Repository<TabSyncRequestEntity>,
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @Inject(forwardRef(() => NotificationsGateway))
    private readonly notificationsGateway: NotificationsGateway,
  ) {}

  /**
   * ⭐ CRÉER UN TAB
   */
  async create(createTabDto: CreateTabDto, userId: string): Promise<TabEntity> {
    console.log('✨ Création tab par:', userId);
    console.log('   creditorId:', createTabDto.creditorId);
    console.log('   debtorId:', createTabDto.debtorId);

    const creator = await this.userRepository.findOne({ where: { id: userId } });
    if (!creator) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // ⭐ Identifier l'autre utilisateur (celui qui n'est pas userId)
    const otherUserId = createTabDto.creditorId === userId 
      ? createTabDto.debtorId 
      : createTabDto.creditorId;

    console.log('   otherUserId identifié:', otherUserId);

    // Créer le tab pour l'utilisateur actuel
    const tab = this.tabRepository.create({
      ...createTabDto,
      userId, // ⭐ Appartient à l'utilisateur
      linkedFriendId: otherUserId, // ⭐ AJOUTER
      status: TabStatus.ACTIVE,
    });

    await this.tabRepository.save(tab);
    console.log('✅ Tab créé avec ID:', tab.id);

    // ⭐ Vérifier si c'est un ami vérifié
    const friendship = await this.friendRepository.findOne({
      where: [
        { 
          userId, 
          friendUserId: otherUserId, 
          status: FriendStatus.ACCEPTED, 
          isVerified: true 
        },
        { 
          userId: otherUserId, 
          friendUserId: userId, 
          status: FriendStatus.ACCEPTED, 
          isVerified: true 
        },
      ],
    });

    console.log('🔍 Ami vérifié trouvé?', !!friendship);

    if (friendship && friendship.isVerified) {
      // ⭐ Créer une demande de synchronisation
      const syncRequest = this.syncRequestRepository.create({
        type: SyncRequestType.CREATE,
        initiatedBy: userId,
        initiatedByName: creator.name,
        targetUserId: otherUserId,
        initiatorTabId: tab.id,
        tabData: {
          description: tab.description,
          amount: tab.amount,
          creditorId: tab.creditorId,
          creditorName: tab.creditorName,
          debtorId: tab.debtorId,
          debtorName: tab.debtorName,
        },
        message: `${creator.name} a ajouté un tab: "${tab.description}" - ${tab.amount}€`,
        status: SyncRequestStatus.PENDING,
      });

      await this.syncRequestRepository.save(syncRequest);
      console.log('✅ SyncRequest créé avec ID:', syncRequest.id);

      // ⭐ Notifier l'autre utilisateur
      this.notificationsGateway.sendToUser(otherUserId, 'tab_sync_request', {
        syncRequestId: syncRequest.id,
        type: 'create',
        from: {
          id: creator.id,
          name: creator.name,
          tag: creator.tag,
        },
        tab: {
          description: tab.description,
          amount: tab.amount,
          creditorName: tab.creditorName,
          debtorName: tab.debtorName,
        },
      });

      console.log(`📤 Notification WebSocket envoyée à ${otherUserId}`);
    } else {
      console.log('⚠️ Pas d\'ami vérifié - pas de notification envoyée');
    }

    return tab;
  }

  /**
   * ⭐ RÉCUPÉRER LES DEMANDES DE SYNCHRO EN ATTENTE
   */
  async getPendingSyncRequests(userId: string): Promise<TabSyncRequestEntity[]> {
    return this.syncRequestRepository.find({
      where: {
        targetUserId: userId,
        status: SyncRequestStatus.PENDING,
      },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * ⭐ RÉPONDRE À UNE DEMANDE DE SYNCHRO
   */
  async respondToSyncRequest(
    userId: string,
    syncRequestId: string,
    action: 'accept' | 'reject',
    rejectionReason?: string,
  ): Promise<TabSyncRequestEntity> {
    const syncRequest = await this.syncRequestRepository.findOne({
      where: { id: syncRequestId },
    });

    if (!syncRequest) {
      throw new NotFoundException('Demande de synchronisation non trouvée');
    }

    if (syncRequest.targetUserId !== userId) {
      throw new ForbiddenException('Cette demande ne vous concerne pas');
    }

    if (syncRequest.status !== SyncRequestStatus.PENDING) {
      throw new BadRequestException('Cette demande a déjà été traitée');
    }

    if (action === 'accept') {
      syncRequest.status = SyncRequestStatus.ACCEPTED;
      syncRequest.respondedAt = new Date();

      // ⭐ Créer le tab chez l'utilisateur cible
      if (syncRequest.type === SyncRequestType.CREATE) {
        const newTab = this.tabRepository.create({
          userId, // ⭐ Appartient à l'utilisateur cible
          ...syncRequest.tabData,
          status: TabStatus.ACTIVE,
          linkedTabId: syncRequest.initiatorTabId,
          linkedFriendId: syncRequest.initiatedBy, // ⭐ AJOUTER
        });

        const savedTab = await this.tabRepository.save(newTab);

        // Mettre à jour le linkedTabId dans le tab de l'initiateur
        await this.tabRepository.update(
          { id: syncRequest.initiatorTabId },
          { linkedTabId: savedTab.id },
        );

        syncRequest.targetTabId = savedTab.id;
        
        console.log(`✅ Tab créé chez l'utilisateur ${userId} avec ID ${savedTab.id}`);
      }

      // ⭐ Remboursement
      else if (syncRequest.type === SyncRequestType.REPAYMENT) {
        // Marquer les deux tabs comme soldés
        await this.tabRepository.update(
          { id: syncRequest.initiatorTabId },
          { status: TabStatus.SETTLED, settledAt: new Date() },
        );

        if (syncRequest.targetTabId) {
          await this.tabRepository.update(
            { id: syncRequest.targetTabId },
            { status: TabStatus.SETTLED, settledAt: new Date() },
          );
        }
        
        console.log(`💰 Remboursement validé pour les tabs ${syncRequest.initiatorTabId} et ${syncRequest.targetTabId}`);
      }
    } else {
      syncRequest.status = SyncRequestStatus.REJECTED;
      syncRequest.rejectionReason = rejectionReason;
      syncRequest.respondedAt = new Date();

      console.log(`❌ Synchronisation refusée pour ${syncRequestId}`);
    }

    await this.syncRequestRepository.save(syncRequest);

    // Notifier l'initiateur
    this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'tab_sync_response', {
      syncRequestId: syncRequest.id,
      action,
      rejectionReason,
    });

    return syncRequest;
  }

  /**
   * ⭐ DÉCLARER UN REMBOURSEMENT
   */
  async declareRepayment(userId: string, tabId: string): Promise<TabSyncRequestEntity> {
    const tab = await this.tabRepository.findOne({ where: { id: tabId, userId } });

    if (!tab) {
      throw new NotFoundException('Tab non trouvé');
    }

    if (tab.status !== TabStatus.ACTIVE) {
      throw new BadRequestException('Ce tab n\'est pas actif');
    }

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // ⭐ Identifier l'autre utilisateur
    let otherUserId: string;
    
    if (tab.linkedFriendId) {
      // Cas 1 : Le tab a déjà un linkedFriendId
      otherUserId = tab.linkedFriendId;
    } else {
      // Cas 2 : Fallback - identifier via creditorId/debtorId
      otherUserId = tab.creditorId === userId ? tab.debtorId : tab.creditorId;
    }

    if (!otherUserId || otherUserId === userId) {
      throw new BadRequestException('Impossible d\'identifier l\'autre utilisateur');
    }

    console.log('💰 Déclaration remboursement:');
    console.log('   userId:', userId);
    console.log('   otherUserId:', otherUserId);
    console.log('   tabId:', tabId);

    // ⭐ Créer une demande de synchronisation pour remboursement
    const syncRequest = this.syncRequestRepository.create({
      type: SyncRequestType.REPAYMENT,
      initiatedBy: userId,
      initiatedByName: user.name,
      targetUserId: otherUserId,
      initiatorTabId: tab.id,
      targetTabId: tab.linkedTabId,
      message: `${user.name} a remboursé: "${tab.description}" - ${tab.amount}€`,
      status: SyncRequestStatus.PENDING,
    });

    await this.syncRequestRepository.save(syncRequest);
    console.log('✅ SyncRequest remboursement créé:', syncRequest.id);

    // Mettre le tab en attente
    tab.status = TabStatus.REPAYMENT_PENDING;
    tab.repaymentRequestedAt = new Date();
    await this.tabRepository.save(tab);

    // Notifier l'autre utilisateur
    this.notificationsGateway.sendToUser(otherUserId, 'tab_sync_request', {
      syncRequestId: syncRequest.id,
      type: 'repayment',
      from: {
        id: user.id,
        name: user.name,
        tag: user.tag,
      },
      tab: {
        description: tab.description,
        amount: tab.amount,
      },
    });

    console.log(`📤 Notification remboursement envoyée à ${otherUserId}`);

    return syncRequest;
  }

  // ========== MÉTHODES EXISTANTES ==========

  async findAllByUser(userId: string): Promise<TabEntity[]> {
    return this.tabRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string, userId: string): Promise<TabEntity> {
    const tab = await this.tabRepository.findOne({
      where: { id, userId },
    });

    if (!tab) {
      throw new NotFoundException('Tab non trouvé');
    }

    return tab;
  }

  async update(id: string, updateTabDto: UpdateTabDto, userId: string): Promise<TabEntity> {
    const tab = await this.findOne(id, userId);
    Object.assign(tab, updateTabDto);
    return this.tabRepository.save(tab);
  }

  async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string }> {
    const tab = await this.findOne(id, userId);
    await this.tabRepository.remove(tab);
    return { deleted: true, message: 'Tab supprimé' };
  }
}