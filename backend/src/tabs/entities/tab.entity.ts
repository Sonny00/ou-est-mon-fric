// src/tabs/entities/tab.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum TabStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  REPAYMENT_REQUESTED = 'repayment_requested',
  SETTLED = 'settled',
  DISPUTED = 'disputed',
}

@Entity('tabs')
export class TabEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  creditorId: string;

  @Column()
  creditorName: string;

  @Column()
  debtorId: string;

  @Column()
  debtorName: string;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column()
  description: string;

  @Column({
    type: 'enum',
    enum: TabStatus,
    default: TabStatus.PENDING,
  })
  status: TabStatus;

  @Column({ nullable: true })
  proofImageUrl: string;

  @Column({ type: 'timestamp', nullable: true })
  repaymentRequestedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  settledAt: Date;

  @Column({ nullable: true })
  disputeReason: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}