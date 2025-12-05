// backend/src/tabs/tabs.service.ts

import { Injectable, NotFoundException, BadRequestException, ForbiddenException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TabEntity, TabStatus } from './entities/tab.entity';
import { TabSyncRequestEntity, SyncRequestType, SyncRequestStatus } from './entities/tab-sync-request.entity';
import { FriendEntity, FriendStatus } from '../friends/entities/friend.entity';
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
      linkedFriendId: otherUserId,
      status: TabStatus.ACTIVE,
    });

    await this.tabRepository.save(tab);
    console.log('✅ Tab créé avec ID:', tab.id);

    // ⭐ NOUVEAU : Notifier l'utilisateur actuel que son tab est créé
 this.notificationsGateway.sendToUser(userId, 'tab_created', {
  tabId: tab.id,
  description: tab.description,
  amount: tab.amount,
});

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

      // ⭐ NOUVEAU : Notifier avec l'événement sync_request_received
     this.notificationsGateway.sendToUser(otherUserId, 'sync_request_received', {

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

      console.log(`📤 Notification sync_request_received envoyée à ${otherUserId}`);
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
        userId,
        ...syncRequest.tabData,
        status: TabStatus.ACTIVE,
        linkedTabId: syncRequest.initiatorTabId,
        linkedFriendId: syncRequest.initiatedBy,
      });

      const savedTab = await this.tabRepository.save(newTab);

      await this.tabRepository.update(
        { id: syncRequest.initiatorTabId },
        { linkedTabId: savedTab.id },
      );

      syncRequest.targetTabId = savedTab.id;
      
      console.log(`✅ Tab créé chez l'utilisateur ${userId} avec ID ${savedTab.id}`);
      
      this.notificationsGateway.sendToUser(userId, 'tab_created', {
        tabId: savedTab.id,
      });

      this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'sync_request_accepted', {
        syncRequestId: syncRequest.id,
        tabId: syncRequest.initiatorTabId,
      });
    }

    // ⭐ Remboursement
    else if (syncRequest.type === SyncRequestType.REPAYMENT) {
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
      
      this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'tab_updated', {
        tabId: syncRequest.initiatorTabId,
        status: 'settled',
      });
      
      this.notificationsGateway.sendToUser(userId, 'tab_updated', {
        tabId: syncRequest.targetTabId,
        status: 'settled',
      });
      
      this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'sync_request_accepted', {
        syncRequestId: syncRequest.id,
        type: 'repayment',
      });
    }
    
    // ⭐ AJOUTER ICI - Suppression
    else if (syncRequest.type === SyncRequestType.DELETE) {
      // Supprimer le tab de l'utilisateur cible
      if (syncRequest.targetTabId) {
        const targetTab = await this.tabRepository.findOne({
          where: { id: syncRequest.targetTabId, userId },
        });
        
        if (targetTab) {
          await this.tabRepository.remove(targetTab);
          
          console.log(`🗑️ Tab supprimé chez l'utilisateur ${userId}: ${syncRequest.targetTabId}`);
          
          // Notifier l'utilisateur cible
          this.notificationsGateway.sendToUser(userId, 'tab_deleted', {
            tabId: syncRequest.targetTabId,
          });
          
          // Notifier l'initiateur
          this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'sync_request_accepted', {
            syncRequestId: syncRequest.id,
            type: 'delete',
          });
        }
      }
    }
    
  } else {
    // ⭐ REFUS
    syncRequest.status = SyncRequestStatus.REJECTED;
    syncRequest.rejectionReason = rejectionReason;
    syncRequest.respondedAt = new Date();

    console.log(`❌ Synchronisation refusée pour ${syncRequestId}`);
    
    this.notificationsGateway.sendToUser(syncRequest.initiatedBy, 'sync_request_rejected', {
      syncRequestId: syncRequest.id,
      type: syncRequest.type,
      rejectionReason,
    });
  }

  await this.syncRequestRepository.save(syncRequest);

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
      otherUserId = tab.linkedFriendId;
    } else {
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
    
    // ⭐ NOUVEAU : Notifier l'utilisateur actuel que son tab est en attente
    this.notificationsGateway.sendToUser(userId, 'tab_updated', {
      tabId: tab.id,
      status: 'repayment_pending',
    });

    // ⭐ NOUVEAU : Notifier avec l'événement sync_request_received
    this.notificationsGateway.sendToUser(otherUserId, 'sync_request_received', {
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

    console.log(`📤 Notification sync_request_received (remboursement) envoyée à ${otherUserId}`);

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
    const updatedTab = await this.tabRepository.save(tab);
    
    // ⭐ NOUVEAU : Notifier l'utilisateur actuel
    this.notificationsGateway.sendToUser(userId, 'tab_updated', {
      tabId: updatedTab.id,
    });
    
    // ⭐ NOUVEAU : Si le tab est lié, notifier l'autre utilisateur
    if (tab.linkedFriendId) {
      this.notificationsGateway.sendToUser(tab.linkedFriendId, 'tab_updated', {
        tabId: tab.linkedTabId,
      });
    }
    
    return updatedTab;
  }

async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string }> {
  const tab = await this.findOne(id, userId);
  
  console.log('🗑️ Demande de suppression du tab:', {
    tabId: id,
    userId,
    linkedFriendId: tab.linkedFriendId,
    linkedTabId: tab.linkedTabId,
  });

  const user = await this.userRepository.findOne({ where: { id: userId } });
  if (!user) {
    throw new NotFoundException('Utilisateur non trouvé');
  }

  // ⭐ Si le tab est lié à un ami vérifié, créer une demande de synchro
  if (tab.linkedFriendId && tab.linkedTabId) {
    // Vérifier si c'est un ami vérifié
    const friendship = await this.friendRepository.findOne({
      where: [
        { 
          userId, 
          friendUserId: tab.linkedFriendId, 
          status: FriendStatus.ACCEPTED, 
          isVerified: true 
        },
        { 
          userId: tab.linkedFriendId, 
          friendUserId: userId, 
          status: FriendStatus.ACCEPTED, 
          isVerified: true 
        },
      ],
    });

    if (friendship && friendship.isVerified) {
      // ⭐ Créer une demande de synchronisation pour suppression
      const syncRequest = this.syncRequestRepository.create({
        type: SyncRequestType.DELETE,
        initiatedBy: userId,
        initiatedByName: user.name,
        targetUserId: tab.linkedFriendId,
        initiatorTabId: tab.id,
        targetTabId: tab.linkedTabId,
        tabData: {
          description: tab.description,
          amount: tab.amount,
          creditorId: tab.creditorId,
          creditorName: tab.creditorName,
          debtorId: tab.debtorId,
          debtorName: tab.debtorName,
        },
        message: `${user.name} a supprimé un tab: "${tab.description}" - ${tab.amount}€`,
        status: SyncRequestStatus.PENDING,
      });

      await this.syncRequestRepository.save(syncRequest);
      console.log('✅ SyncRequest suppression créé:', syncRequest.id);

      // Supprimer le tab de l'utilisateur actuel
      await this.tabRepository.remove(tab);

      // Notifier l'utilisateur actuel
      this.notificationsGateway.sendToUser(userId, 'tab_deleted', {
        tabId: id,
      });

      // ⭐ Notifier l'autre utilisateur avec sync_request_received
      this.notificationsGateway.sendToUser(tab.linkedFriendId, 'sync_request_received', {
        syncRequestId: syncRequest.id,
        type: 'delete',
        from: {
          id: user.id,
          name: user.name,
          tag: user.tag,
        },
        tab: {
          description: tab.description,
          amount: tab.amount,
          creditorName: tab.creditorName,
          debtorName: tab.debtorName,
        },
      });

      console.log(`📤 Notification sync_request_received (suppression) envoyée à ${tab.linkedFriendId}`);

      return { deleted: true, message: 'Demande de suppression envoyée' };
    }
  }

  // ⭐ Si pas d'ami vérifié ou pas de tab lié, suppression directe
  const linkedFriendId = tab.linkedFriendId;
  const linkedTabId = tab.linkedTabId;
  
  await this.tabRepository.remove(tab);
  
  // Notifier l'utilisateur actuel
  this.notificationsGateway.sendToUser(userId, 'tab_deleted', {
    tabId: id,
  });
  
  // Si le tab était lié, notifier l'autre utilisateur
  if (linkedFriendId && linkedTabId) {
    this.notificationsGateway.sendToUser(linkedFriendId, 'tab_deleted', {
      tabId: linkedTabId,
    });
  }
  
  return { deleted: true, message: 'Tab supprimé' };
}

}