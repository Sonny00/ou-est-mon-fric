// backend/src/friends/friends.service.ts

import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FriendEntity, FriendStatus } from './entities/friend.entity';
import { TabEntity } from '../tabs/entities/tab.entity';
import { User } from '../users/entities/user.entity';
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';
import { SendFriendRequestDto } from './dto/send-friend-request.dto';
import { FriendRequestResponse } from './dto/respond-friend-request.dto';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
    @InjectRepository(TabEntity)
    private readonly tabRepository: Repository<TabEntity>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  // ========== MÉTHODES EXISTANTES (inchangées) ==========

  async findAllByUser(userId: string): Promise<FriendEntity[]> {
    console.log('🔍 Finding friends for user:', userId);
    return this.friendRepository.find({
      where: { userId },
      relations: ['friendUser'],
      order: { addedAt: 'DESC' },
    });
  }

  async findOne(id: string, userId: string): Promise<FriendEntity> {
    const friend = await this.friendRepository.findOne({
      where: { id, userId },
      relations: ['friendUser'],
    });

    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }

    return friend;
  }

  async create(createFriendDto: CreateFriendDto, userId: string): Promise<FriendEntity> {
    console.log('✨ Creating non-verified friend for user:', userId);
    const friend = this.friendRepository.create({
      ...createFriendDto,
      userId,
      isVerified: false,
      status: FriendStatus.ACCEPTED,
    });
    return this.friendRepository.save(friend);
  }

  async update(
    id: string,
    updateFriendDto: UpdateFriendDto,
    userId: string,
  ): Promise<FriendEntity> {
    const friend = await this.findOne(id, userId);
    Object.assign(friend, updateFriendDto);
    return this.friendRepository.save(friend);
  }

  async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string; deletedTabsCount: number }> {
    console.log('🗑️ === DÉBUT SUPPRESSION EN CASCADE ===');
    
    try {
      const friend = await this.findOne(id, userId);
      console.log('✅ Ami trouvé:', friend.name);
      
      const tabsCount = await this.tabRepository.count({
        where: [
          { debtorId: id },
          { creditorId: id },
        ],
      });
      console.log(`📊 Nombre de tabs à supprimer: ${tabsCount}`);
      
      await this.tabRepository.delete({ debtorId: id });
      await this.tabRepository.delete({ creditorId: id });
      console.log('✅ Tabs supprimées');
      
      if (friend.isVerified && friend.friendUserId) {
        const reciprocal = await this.friendRepository.findOne({
          where: { userId: friend.friendUserId, friendUserId: userId },
        });
        if (reciprocal) {
          await this.friendRepository.remove(reciprocal);
          console.log('✅ Relation réciproque supprimée');
        }
      }
      
      await this.friendRepository.remove(friend);
      console.log('✅ Ami supprimé');
      
      return { 
        deleted: true, 
        message: `Friend and ${tabsCount} associated tabs deleted successfully`,
        deletedTabsCount: tabsCount,
      };
      
    } catch (error) {
      console.error('❌ Erreur suppression:', error);
      throw error;
    }
  }

  // ========== ⭐ NOUVELLES MÉTHODES POUR AMIS VÉRIFIÉS (PAR TAG) ==========

  /**
   * Envoyer une invitation à un ami vérifié PAR TAG
   */
  async sendFriendRequest(
    userId: string,
    dto: SendFriendRequestDto,
  ): Promise<{ friend: FriendEntity; reciprocalFriend: FriendEntity }> {
    console.log(`👥 Envoi invitation de ${userId} au tag ${dto.tag}`);

    // 1. Trouver l'utilisateur cible PAR TAG
    const targetUser = await this.userRepository.findOne({
      where: { tag: dto.tag }, // ⭐ Changé
    });

    if (!targetUser) {
      throw new NotFoundException(`Aucun utilisateur trouvé avec le tag "${dto.tag}"`);
    }

    // Vérifier que l'utilisateur ne s'ajoute pas lui-même
    const currentUser = await this.userRepository.findOne({ where: { id: userId } });
    
    if (currentUser.tag === dto.tag) {
      throw new BadRequestException('Tu ne peux pas t\'ajouter toi-même');
    }

    // 2. Vérifier si déjà amis
    const existing = await this.friendRepository.findOne({
      where: { userId, friendUserId: targetUser.id },
    });

    if (existing) {
      if (existing.status === FriendStatus.ACCEPTED) {
        throw new ConflictException('Vous êtes déjà amis');
      } else if (existing.status === FriendStatus.PENDING) {
        throw new ConflictException('Une invitation est déjà en attente');
      }
    }

    // 3. Créer la relation bidirectionnelle
    const friend = this.friendRepository.create({
      userId,
      friendUserId: targetUser.id,
      name: targetUser.name,
      email: targetUser.email,
      isVerified: true,
      status: FriendStatus.PENDING,
    });

    const reciprocalFriend = this.friendRepository.create({
      userId: targetUser.id,
      friendUserId: userId,
      name: currentUser.name,
      email: currentUser.email,
      isVerified: true,
      status: FriendStatus.PENDING,
    });

    await this.friendRepository.save([friend, reciprocalFriend]);

    console.log(`✅ Invitation envoyée à ${targetUser.name} (${targetUser.tag})`);
    return { friend, reciprocalFriend };
  }

  /**
   * Récupérer les invitations reçues
   */
  async getReceivedRequests(userId: string): Promise<FriendEntity[]> {
    return this.friendRepository.find({
      where: {
        userId,
        status: FriendStatus.PENDING,
        isVerified: true,
      },
      relations: ['friendUser'],
      order: { addedAt: 'DESC' },
    });
  }

  /**
   * Récupérer les invitations envoyées
   */
  async getSentRequests(userId: string): Promise<FriendEntity[]> {
    // ⭐ FIX : La bonne requête pour les invitations ENVOYÉES
    const sentRequests = await this.friendRepository
      .createQueryBuilder('friend')
      .leftJoinAndSelect('friend.friendUser', 'friendUser')
      .where('friend.userId = :userId', { userId })
      .andWhere('friend.status = :status', { status: FriendStatus.PENDING })
      .andWhere('friend.isVerified = :isVerified', { isVerified: true })
      .andWhere('friend.friendUserId IS NOT NULL')
      .orderBy('friend.addedAt', 'DESC')
      .getMany();

    return sentRequests;
  }

  /**
   * Accepter ou refuser une invitation
   */
  async respondToRequest(
    userId: string,
    friendId: string,
    response: FriendRequestResponse,
  ): Promise<FriendEntity | null> {
    console.log(`👥 Réponse à l'invitation ${friendId}: ${response}`);

    const friend = await this.friendRepository.findOne({
      where: { id: friendId, userId, status: FriendStatus.PENDING },
      relations: ['friendUser'],
    });

    if (!friend || !friend.friendUserId) {
      throw new NotFoundException('Invitation non trouvée');
    }

    const reciprocal = await this.friendRepository.findOne({
      where: {
        userId: friend.friendUserId,
        friendUserId: userId,
        status: FriendStatus.PENDING,
      },
    });

    if (response === FriendRequestResponse.ACCEPT) {
      friend.status = FriendStatus.ACCEPTED;
      if (reciprocal) {
        reciprocal.status = FriendStatus.ACCEPTED;
        await this.friendRepository.save([friend, reciprocal]);
      } else {
        await this.friendRepository.save(friend);
      }

      console.log(`✅ Invitation acceptée`);
      return friend;
    } else {
      if (reciprocal) {
        await this.friendRepository.remove([friend, reciprocal]);
      } else {
        await this.friendRepository.remove(friend);
      }

      console.log(`❌ Invitation refusée`);
      return null;
    }
  }

  /**
   * Annuler une invitation envoyée
   */
  async cancelRequest(userId: string, friendId: string): Promise<void> {
    const friend = await this.friendRepository.findOne({
      where: { id: friendId, userId, status: FriendStatus.PENDING },
    });

    if (!friend || !friend.friendUserId) {
      throw new NotFoundException('Invitation non trouvée');
    }

    const reciprocal = await this.friendRepository.findOne({
      where: {
        userId: friend.friendUserId,
        friendUserId: userId,
        status: FriendStatus.PENDING,
      },
    });

    if (reciprocal) {
      await this.friendRepository.remove([friend, reciprocal]);
    } else {
      await this.friendRepository.remove(friend);
    }

    console.log(`🗑️ Invitation annulée`);
  }
}