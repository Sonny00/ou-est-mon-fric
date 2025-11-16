// backend/src/tabs/tabs.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TabEntity, TabStatus } from './entities/tab.entity';
import { CreateTabDto } from './dto/create-tab.dto';
import { UpdateTabDto } from './dto/update-tab.dto';

@Injectable()
export class TabsService {
  constructor(
    @InjectRepository(TabEntity)
    private readonly tabRepository: Repository<TabEntity>,
  ) {}

  // Trouver toutes les tabs d'un utilisateur (créditeur OU débiteur)
  async findAllByUser(userId: string): Promise<TabEntity[]> {
    console.log('🔍 Finding tabs for user:', userId); // Debug
    return this.tabRepository
      .createQueryBuilder('tab')
      .where('tab.creditorId = :userId OR tab.debtorId = :userId', { userId })
      .orderBy('tab.createdAt', 'DESC')
      .getMany();
  }

  // Trouver une tab par ID (avec vérification que l'user est impliqué)
  async findOne(id: string, userId: string): Promise<TabEntity> {
    const tab = await this.tabRepository
      .createQueryBuilder('tab')
      .where('tab.id = :id', { id })
      .andWhere('(tab.creditorId = :userId OR tab.debtorId = :userId)', { userId })
      .getOne();

    if (!tab) {
      throw new NotFoundException(`Tab with ID ${id} not found or access denied`);
    }

    return tab;
  }

  // Créer une tab
  async create(createTabDto: CreateTabDto, userId: string): Promise<TabEntity> {
  console.log('✨ Creating tab for user:', userId);
  
  // Accepter les IDs tels quels (userId ou friendId)
  const tab = this.tabRepository.create({
    ...createTabDto,
    status: TabStatus.PENDING,
  });

  console.log('📤 Tab data:', {
    creditorId: tab.creditorId,
    debtorId: tab.debtorId,
  });

  return this.tabRepository.save(tab);
}

  // Modifier une tab
  async update(id: string, updateTabDto: UpdateTabDto, userId: string): Promise<TabEntity> {
    const tab = await this.findOne(id, userId);
    Object.assign(tab, updateTabDto);
    return this.tabRepository.save(tab);
  }

  // Supprimer une tab
  async remove(id: string, userId: string): Promise<{ deleted: boolean; message: string }> {
    const tab = await this.findOne(id, userId);
    await this.tabRepository.remove(tab);
    return { deleted: true, message: 'Tab deleted successfully' };
  }

  // Confirmer une tab
  async confirmTab(id: string, userId: string): Promise<TabEntity> {
    const tab = await this.findOne(id, userId);
    tab.status = TabStatus.CONFIRMED;
    return this.tabRepository.save(tab);
  }

  // Demander un remboursement
  async requestRepayment(id: string, userId: string, proofImageUrl?: string): Promise<TabEntity> {
    const tab = await this.findOne(id, userId);
    tab.status = TabStatus.REPAYMENT_REQUESTED;
    tab.repaymentRequestedAt = new Date();
    if (proofImageUrl) {
      tab.proofImageUrl = proofImageUrl;
    }
    return this.tabRepository.save(tab);
  }

  // Confirmer un remboursement
  async confirmRepayment(id: string, userId: string): Promise<TabEntity> {
    const tab = await this.findOne(id, userId);
    tab.status = TabStatus.SETTLED;
    tab.settledAt = new Date();
    return this.tabRepository.save(tab);
  }
}