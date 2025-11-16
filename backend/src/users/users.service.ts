// backend/src/users/users.service.ts

import { Injectable, ConflictException } from '@nestjs/common';
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

  // ⭐ NOUVEAU : Générer un tag unique
  private async generateUniqueTag(name: string): Promise<string> {
    // Nettoyer le nom (enlever espaces, caractères spéciaux, max 20 chars)
    const baseName = name
      .replace(/[^a-zA-Z0-9]/g, '') // Garder seulement lettres et chiffres
      .substring(0, 20);
    
    let tag: string;
    let isUnique = false;
    let attempts = 0;
    const maxAttempts = 10;

    while (!isUnique && attempts < maxAttempts) {
      const randomNumber = Math.floor(1000 + Math.random() * 9000); // 1000-9999
      tag = `${baseName}#${randomNumber}`;
      
      const existing = await this.userRepository.findOne({ where: { tag } });
      if (!existing) {
        isUnique = true;
      }
      attempts++;
    }

    if (!isUnique) {
      // Fallback : utiliser un UUID partiel
      const uuid = Math.random().toString(36).substring(2, 8).toUpperCase();
      tag = `${baseName}#${uuid}`;
    }

    return tag;
  }

  // ⭐ MODIFIER : Générer le tag à la création
  async create(userData: Partial<User>): Promise<User> {
    // Vérifier si l'email existe déjà
    if (userData.email) {
      const existingEmail = await this.userRepository.findOne({ 
        where: { email: userData.email } 
      });
      if (existingEmail) {
        throw new ConflictException('Email already exists');
      }
    }

    // Vérifier si le téléphone existe déjà
    if (userData.phoneNumber) {
      const existingPhone = await this.userRepository.findOne({ 
        where: { phoneNumber: userData.phoneNumber } 
      });
      if (existingPhone) {
        throw new ConflictException('Phone number already exists');
      }
    }

    // ⭐ Générer le tag unique
    const tag = await this.generateUniqueTag(userData.name);

    const user = this.userRepository.create({
      ...userData,
      tag, // ⭐ Ajouter le tag
    });

    return this.userRepository.save(user);
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  // ⭐ NOUVEAU : Rechercher par tag
  async findByTag(tag: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { tag } });
  }

  async getUserStats(userId: string): Promise<UserStatsDto> {
    const activeTabs = await this.tabRepository
      .createQueryBuilder('tab')
      .where('(tab.creditorId = :userId OR tab.debtorId = :userId)', { userId })
      .andWhere('tab.status != :status', { status: TabStatus.SETTLED })
      .getCount();

    const totalFriends = await this.friendRepository
      .createQueryBuilder('friend')
      .where('friend.userId = :userId', { userId })
      .getCount();

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