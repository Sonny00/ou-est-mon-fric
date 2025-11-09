// backend/src/friends/friends.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FriendEntity } from './entities/friend.entity';
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
  ) {}

  // Renommer findAll en findAllByUser
  async findAllByUser(userId: string): Promise<FriendEntity[]> {
    console.log('🔍 Finding friends for user:', userId); // Debug
    return this.friendRepository.find({
      where: { userId },
      order: { addedAt: 'DESC' },
    });
  }

  // Ajouter userId à findOne
  async findOne(id: string, userId: string): Promise<FriendEntity> {
    const friend = await this.friendRepository.findOne({
      where: { id, userId },
    });

    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }

    return friend;
  }

  // Ajouter userId à create
  async create(createFriendDto: CreateFriendDto, userId: string): Promise<FriendEntity> {
    console.log('✨ Creating friend for user:', userId); // Debug
    const friend = this.friendRepository.create({
      ...createFriendDto,
      userId,
    });
    return this.friendRepository.save(friend);
  }

  // Ajouter userId à update
  async update(
    id: string,
    updateFriendDto: UpdateFriendDto,
    userId: string,
  ): Promise<FriendEntity> {
    const friend = await this.findOne(id, userId);
    Object.assign(friend, updateFriendDto);
    return this.friendRepository.save(friend);
  }

  // Ajouter userId à remove
  async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string }> {
    const friend = await this.findOne(id, userId);
    await this.friendRepository.remove(friend);
    return { deleted: true, message: 'Friend deleted successfully' };
  }
}