// src/tabs/tabs.service.ts

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

  async findAll(): Promise<TabEntity[]> {
    return this.tabRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<TabEntity> {
    const tab = await this.tabRepository.findOne({ where: { id } });
    if (!tab) {
      throw new NotFoundException(`Tab with ID ${id} not found`);
    }
    return tab;
  }

  async create(createTabDto: CreateTabDto): Promise<TabEntity> {
    const tab = this.tabRepository.create({
      ...createTabDto,
      status: TabStatus.PENDING,
    });
    return this.tabRepository.save(tab);
  }

  async update(id: string, updateTabDto: UpdateTabDto): Promise<TabEntity> {
    const tab = await this.findOne(id);
    
    Object.assign(tab, updateTabDto);
    
    return this.tabRepository.save(tab);
  }

  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    const tab = await this.findOne(id);
    await this.tabRepository.remove(tab);
    return { deleted: true, message: 'Tab deleted successfully' };
  }

  async confirmTab(id: string): Promise<TabEntity> {
    const tab = await this.findOne(id);
    tab.status = TabStatus.CONFIRMED;
    return this.tabRepository.save(tab);
  }

  async requestRepayment(id: string, proofImageUrl?: string): Promise<TabEntity> {
    const tab = await this.findOne(id);
    tab.status = TabStatus.REPAYMENT_REQUESTED;
    tab.repaymentRequestedAt = new Date();
    if (proofImageUrl) {
      tab.proofImageUrl = proofImageUrl;
    }
    return this.tabRepository.save(tab);
  }

  async confirmRepayment(id: string): Promise<TabEntity> {
    const tab = await this.findOne(id);
    tab.status = TabStatus.SETTLED;
    tab.settledAt = new Date();
    return this.tabRepository.save(tab);
  }
}