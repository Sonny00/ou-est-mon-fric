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
import { NotificationsGateway } from '../notifications/notifications.gateway';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
    @InjectRepository(TabEntity)
    private readonly tabRepository: Repository<TabEntity>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly notificationsGateway: NotificationsGateway, // ⭐ AJOUTER
  ) {}

 // backend/src/friends/friends.service.ts

// backend/src/friends/friends.service.ts

// backend/src/friends/friends.service.ts

// backend/src/friends/friends.service.ts

// backend/src/friends/friends.service.ts

async findAllByUser(userId: string): Promise<FriendEntity[]> {
  console.log('🔍 Finding friends for user:', userId);
  
  const friends = await this.friendRepository.find({
    where: [
      { 
        userId,
        status: FriendStatus.ACCEPTED,
        isVerified: true,
      },
      { 
        friendUserId: userId,
        status: FriendStatus.ACCEPTED,
        isVerified: true,
      },
    ],
    relations: ['friendUser', 'user'], // ⭐ IMPORTANT : Charger les relations
    order: { addedAt: 'DESC' },
  });

  console.log(`📊 Relations trouvées AVANT filtrage: ${friends.length}`);
  
  friends.forEach(f => {
    console.log(`   - ID: ${f.id}, userId: ${f.userId}, friendUserId: ${f.friendUserId}, name: ${f.name}`);
  });

  const uniqueFriendsMap = new Map<string, FriendEntity>();
  
  for (const friend of friends) {
    if (friend.userId === friend.friendUserId) {
      console.log(`   ⚠️ IGNORÉ (auto-relation): ${friend.id}`);
      continue;
    }
    
    let otherUserId: string;
    
    if (friend.userId === userId) {
      otherUserId = friend.friendUserId!;
      
      // ⭐ CORRIGER : Mettre à jour le name avec celui de friendUser
      if (friend.friendUser) {
        friend.name = friend.friendUser.name;
        friend.email = friend.friendUser.email;
        console.log(`   📝 Mise à jour name: ${friend.name} (friendUser)`);
      }
    } else {
      otherUserId = friend.userId;
      
      // ⭐ CORRIGER : Mettre à jour le name avec celui de user
      if (friend.user) {
        friend.name = friend.user.name;
        friend.email = friend.user.email;
        console.log(`   📝 Mise à jour name: ${friend.name} (user)`);
      }
    }
    
    if (otherUserId === userId) {
      console.log(`   ⚠️ IGNORÉ (c'est moi): ${friend.id}`);
      continue;
    }
    
    if (!uniqueFriendsMap.has(otherUserId)) {
      uniqueFriendsMap.set(otherUserId, friend);
      console.log(`   ✅ AJOUTÉ: ${friend.id}, ami: ${otherUserId}, name: ${friend.name}`);
    } else {
      console.log(`   ⚠️ DUPLIQUÉ (déjà ajouté): ${friend.id}`);
    }
  }

  const result = Array.from(uniqueFriendsMap.values());
  console.log(`✅ Amis uniques APRÈS filtrage: ${result.length}`);
  
  return result;
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

 // backend/src/friends/friends.service.ts

async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string; deletedTabsCount: number }> {
  console.log('🗑️ === DÉBUT SUPPRESSION ===');
  console.log(`   Friend ID: ${id}`);
  console.log(`   User ID: ${userId}`);
  
  try {
    const friend = await this.friendRepository.findOne({
      where: { id },
      relations: ['friendUser', 'user'],
    });

    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }

    console.log(`   Ami trouvé:`);
    console.log(`     - userId: ${friend.userId}`);
    console.log(`     - friendUserId: ${friend.friendUserId}`);
    console.log(`     - isVerified: ${friend.isVerified}`);

    const canDelete = friend.userId === userId || friend.friendUserId === userId;
    
    if (!canDelete) {
      throw new NotFoundException(`You don't have permission to delete this friend`);
    }

    const tabsCount = await this.tabRepository.count({
      where: [
        { debtorId: id },
        { creditorId: id },
      ],
    });
    console.log(`📊 Tabs à supprimer: ${tabsCount}`);
    
    if (tabsCount > 0) {
      await this.tabRepository.delete({ debtorId: id });
      await this.tabRepository.delete({ creditorId: id });
      console.log('✅ Tabs supprimées');
    }
    
    // ⭐ IDENTIFIER l'autre utilisateur AVANT la suppression
    let otherUserId: string | null = null;
    if (friend.isVerified && friend.friendUserId) {
      otherUserId = friend.userId === userId ? friend.friendUserId : friend.userId;
    }
    
    if (friend.isVerified && friend.friendUserId) {
      console.log('🔍 Recherche de toutes les relations entre les utilisateurs...');
      
      const allRelations = await this.friendRepository.find({
        where: [
          { userId: friend.userId, friendUserId: friend.friendUserId },
          { userId: friend.friendUserId, friendUserId: friend.userId },
        ],
      });

      console.log(`   Trouvé ${allRelations.length} relation(s) à supprimer`);
      
      if (allRelations.length > 0) {
        await this.friendRepository.remove(allRelations);
        console.log(`✅ ${allRelations.length} relation(s) supprimée(s)`);
      }
    } else {
      await this.friendRepository.remove(friend);
      console.log('✅ Ami non-vérifié supprimé');
    }
    
    // ⭐ AJOUTER : Notifier l'autre utilisateur via WebSocket
    if (otherUserId) {
      const currentUser = await this.userRepository.findOne({ where: { id: userId } });
      
      this.notificationsGateway.sendToUser(otherUserId, 'friend_deleted', {
        deletedBy: {
          id: currentUser?.id,
          name: currentUser?.name,
          tag: currentUser?.tag,
        },
      });
      
      console.log(`📤 Notification de suppression envoyée à ${otherUserId}`);
    }
    
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

  async sendFriendRequest(
    userId: string,
    dto: SendFriendRequestDto,
  ): Promise<{ friend: FriendEntity; reciprocalFriend: FriendEntity }> {
    console.log(`👥 Envoi invitation de ${userId} au tag ${dto.tag}`);

    const currentUser = await this.userRepository.findOne({ where: { id: userId } });
    if (!currentUser) {
      throw new NotFoundException('Utilisateur actuel non trouvé');
    }

    const targetUser = await this.userRepository.findOne({
      where: { tag: dto.tag },
    });

    if (!targetUser) {
      throw new NotFoundException(`Aucun utilisateur trouvé avec le tag "${dto.tag}"`);
    }

    if (currentUser.tag === dto.tag) {
      throw new BadRequestException('Tu ne peux pas t\'ajouter toi-même');
    }

    const existingOutgoing = await this.friendRepository.findOne({
      where: { userId, friendUserId: targetUser.id },
    });

    const existingIncoming = await this.friendRepository.findOne({
      where: { userId: targetUser.id, friendUserId: userId },
    });

    const existing = existingOutgoing || existingIncoming;

    if (existing) {
      if (existing.status === FriendStatus.ACCEPTED) {
        throw new ConflictException('Vous êtes déjà amis');
      } else if (existing.status === FriendStatus.PENDING) {
        if (existingOutgoing) {
          throw new ConflictException('Tu as déjà envoyé une invitation à cet utilisateur');
        } else {
          throw new ConflictException('Cet utilisateur t\'a déjà envoyé une invitation. Vérifie tes invitations reçues.');
        }
      }
    }

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

    // ⭐ AJOUTER : Envoyer notification WebSocket
    this.notificationsGateway.sendToUser(targetUser.id, 'friend_request_received', {
      requestId: reciprocalFriend.id,
      from: {
        id: currentUser.id,
        name: currentUser.name,
        tag: currentUser.tag,
      },
    });

    console.log(`✅ Invitation envoyée à ${targetUser.name} (${targetUser.tag})`);
    return { friend, reciprocalFriend };
  }

  async getReceivedRequests(userId: string): Promise<FriendEntity[]> {
    console.log(`📥 Récupération des invitations REÇUES pour ${userId}`);
    
    const requests = await this.friendRepository.find({
      where: {
        friendUserId: userId,
        status: FriendStatus.PENDING,
        isVerified: true,
      },
      relations: ['user'],
      order: { addedAt: 'DESC' },
    });

    console.log(`✅ ${requests.length} invitations reçues trouvées`);
    return requests;
  }

  async getSentRequests(userId: string): Promise<FriendEntity[]> {
    console.log(`📤 Récupération des invitations ENVOYÉES pour ${userId}`);
    
    const sentRequests = await this.friendRepository.find({
      where: {
        userId,
        status: FriendStatus.PENDING,
        isVerified: true,
      },
      relations: ['friendUser'],
      order: { addedAt: 'DESC' },
    });

    console.log(`✅ ${sentRequests.length} invitations envoyées trouvées`);
    return sentRequests;
  }

  async respondToRequest(
    userId: string,
    friendId: string,
    response: FriendRequestResponse,
  ): Promise<FriendEntity | null> {
    console.log(`👥 Réponse à l'invitation ${friendId}: ${response}`);
    console.log(`   User ID qui répond: ${userId}`);

    const invitation = await this.friendRepository.findOne({
      where: { 
        id: friendId,
        status: FriendStatus.PENDING 
      },
      relations: ['user', 'friendUser'],
    });

    if (!invitation) {
      throw new NotFoundException('Invitation non trouvée');
    }

    console.log(`   Invitation trouvée:`);
    console.log(`     - userId: ${invitation.userId}`);
    console.log(`     - friendUserId: ${invitation.friendUserId}`);

    const canRespond = invitation.userId === userId || invitation.friendUserId === userId;
    
    if (!canRespond) {
      throw new NotFoundException('Cette invitation ne te concerne pas');
    }

    const allPendingRelations = await this.friendRepository.find({
      where: [
        { 
          userId: invitation.userId, 
          friendUserId: invitation.friendUserId,
          status: FriendStatus.PENDING,
        },
        { 
          userId: invitation.friendUserId, 
          friendUserId: invitation.userId,
          status: FriendStatus.PENDING,
        },
      ],
    });

    console.log(`   Trouvé ${allPendingRelations.length} relation(s) pending entre ces utilisateurs`);

    if (response === FriendRequestResponse.ACCEPT) {
      allPendingRelations.forEach(rel => {
        rel.status = FriendStatus.ACCEPTED;
      });
      
      await this.friendRepository.save(allPendingRelations);

      // ⭐ AJOUTER : Notifier l'envoyeur
      const otherUserId = invitation.userId === userId 
        ? invitation.friendUserId 
        : invitation.userId;
      
      if (otherUserId) {
        const acceptingUser = await this.userRepository.findOne({ where: { id: userId } });
        
        this.notificationsGateway.sendToUser(otherUserId, 'friend_request_accepted', {
          from: {
            id: acceptingUser?.id,
            name: acceptingUser?.name,
            tag: acceptingUser?.tag,
          },
        });
      }

      console.log(`✅ ${allPendingRelations.length} relation(s) acceptée(s) - Les deux utilisateurs sont maintenant amis`);
      
      return invitation;
    } else {
      await this.friendRepository.remove(allPendingRelations);
      console.log(`❌ ${allPendingRelations.length} relation(s) refusée(s) et supprimée(s)`);
      
      return null;
    }
  }

  async cancelRequest(userId: string, friendId: string): Promise<void> {
    console.log(`🗑️ Annulation de l'invitation ${friendId}`);

    const sentRequest = await this.friendRepository.findOne({
      where: { 
        id: friendId, 
        userId,
        status: FriendStatus.PENDING 
      },
    });

    if (!sentRequest || !sentRequest.friendUserId) {
      throw new NotFoundException('Invitation non trouvée');
    }

    const reciprocal = await this.friendRepository.findOne({
      where: {
        userId: sentRequest.friendUserId,
        friendUserId: userId,
        status: FriendStatus.PENDING,
      },
    });

    if (reciprocal) {
      await this.friendRepository.remove([sentRequest, reciprocal]);
    } else {
      await this.friendRepository.remove(sentRequest);
    }

    console.log(`🗑️ Invitation annulée avec succès`);
  }
}