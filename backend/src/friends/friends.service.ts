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

  async findAll(): Promise<FriendEntity[]> {
    return this.friendRepository.find({
      order: { addedAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<FriendEntity> {
    const friend = await this.friendRepository.findOne({ where: { id } });
    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }
    return friend;
  }

  async create(createFriendDto: CreateFriendDto): Promise<FriendEntity> {
    const friend = this.friendRepository.create({
      ...createFriendDto,
      userId: 'current_user',
    });
    return this.friendRepository.save(friend);
  }

  async update(id: string, updateFriendDto: UpdateFriendDto): Promise<FriendEntity> {
    const friend = await this.findOne(id);
    Object.assign(friend, updateFriendDto);
    return this.friendRepository.save(friend);
  }

  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    const friend = await this.findOne(id);
    await this.friendRepository.remove(friend);
    return { deleted: true, message: 'Friend deleted successfully' };
  }
}
