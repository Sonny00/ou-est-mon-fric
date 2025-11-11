import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FriendEntity } from './entities/friend.entity';
import { TabEntity } from '../tabs/entities/tab.entity'; // ← Importer
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
    @InjectRepository(TabEntity) // ← Injecter le repository des tabs
    private readonly tabRepository: Repository<TabEntity>,
  ) {}

  async findAllByUser(userId: string): Promise<FriendEntity[]> {
    console.log('🔍 Finding friends for user:', userId);
    return this.friendRepository.find({
      where: { userId },
      order: { addedAt: 'DESC' },
    });
  }

  async findOne(id: string, userId: string): Promise<FriendEntity> {
    const friend = await this.friendRepository.findOne({
      where: { id, userId },
    });

    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }

    return friend;
  }

  async create(createFriendDto: CreateFriendDto, userId: string): Promise<FriendEntity> {
    console.log('✨ Creating friend for user:', userId);
    const friend = this.friendRepository.create({
      ...createFriendDto,
      userId,
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
    console.log('Friend ID:', id);
    console.log('User ID:', userId);
    
    try {
      // 1. Vérifier que l'ami existe
      const friend = await this.findOne(id, userId);
      console.log('✅ Ami trouvé:', friend.name);
      
      // 2. Compter les tabs associées (pour info)
      const tabsCount = await this.tabRepository.count({
        where: [
          { debtorId: id },
          { creditorId: id },
        ],
      });
      console.log(`📊 Nombre de tabs à supprimer: ${tabsCount}`);
      
      // 3. Supprimer manuellement les tabs (au cas où CASCADE ne marche pas)
      await this.tabRepository.delete({ debtorId: id });
      await this.tabRepository.delete({ creditorId: id });
      console.log('✅ Tabs supprimées manuellement');
      
      // 4. Supprimer l'ami
      await this.friendRepository.remove(friend);
      console.log('✅ Ami supprimé');
      
      console.log('✅ === SUPPRESSION EN CASCADE RÉUSSIE ===');
      return { 
        deleted: true, 
        message: `Friend and ${tabsCount} associated tabs deleted successfully`,
        deletedTabsCount: tabsCount,
      };
      
    } catch (error) {
      console.error('❌ === ERREUR LORS DE LA SUPPRESSION ===');
      console.error('Type d\'erreur:', error.constructor.name);
      console.error('Message:', error.message);
      console.error('Stack:', error.stack);
      throw error;
    }
  }
}