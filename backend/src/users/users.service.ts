// backend/src/users/users.service.ts

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { TabEntity, TabStatus } from '../tabs/entities/tab.entity';
import { FriendEntity } from '../friends/entities/friend.entity';
import { UserStatsDto } from './dto/user-stats.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(TabEntity)
    private readonly tabRepository: Repository<TabEntity>,
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async getUserStats(userId: string): Promise<UserStatsDto> {
    const activeTabs = await this.tabRepository
      .createQueryBuilder('tab')
      .where('(tab.creditorId = :userId OR tab.debtorId = :userId)', { userId })
      .andWhere('tab.status != :status', { status: TabStatus.SETTLED })
      .getCount();

    // Compter les amis
    const totalFriends = await this.friendRepository
      .createQueryBuilder('friend')
      .where('friend.userId = :userId', { userId })
      .getCount();

    // Calculer les montants
    const tabs = await this.tabRepository
      .createQueryBuilder('tab')
      .where('(tab.creditorId = :userId OR tab.debtorId = :userId)', { userId })
      .andWhere('tab.status != :status', { status: TabStatus.SETTLED })
      .getMany();

    let totalOwed = 0;
    let totalDue = 0;

    tabs.forEach(tab => {
      if (tab.creditorId === userId) {
        totalOwed += tab.amount;
      } else {
        totalDue += tab.amount;
      }
    });

    const balance = totalOwed - totalDue;

    return {
      activeTabs,
      totalFriends,
      totalOwed,
      totalDue,
      balance,
    };
  }
}
