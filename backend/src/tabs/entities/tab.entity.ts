// backend/src/tabs/entities/tab.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum TabStatus {
  ACTIVE = 'active',                       // ⭐ Tab active
  REPAYMENT_PENDING = 'repayment_pending', // Remboursement en attente
  SETTLED = 'settled',                     // Remboursé
}

@Entity('tabs')
export class TabEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // ⭐ NOUVEAU : À qui appartient ce tab
  @Column('uuid')
  userId: string;

  // ========== PAS DE RELATIONS = PAS DE CONTRAINTES ==========
  @Column('uuid')
  creditorId: string; // Peut être userId OU friendId

  @Column()
  creditorName: string;

  @Column('uuid')
  debtorId: string; // Peut être userId OU friendId

  @Column()
  debtorName: string;
  // ==========================================================

  @Column('decimal', {
    precision: 10,
    scale: 2,
    transformer: {
      to: (value: number) => value,
      from: (value: string) => parseFloat(value),
    },
  })
  amount: number;

  @Column()
  description: string;

  @Column({
    type: 'enum',
    enum: TabStatus,
    default: TabStatus.ACTIVE,
  })
  status: TabStatus;

  // ⭐ NOUVEAU : ID du tab lié chez l'ami (si synchronisé)
  @Column('uuid', { nullable: true })
  linkedTabId: string;

  // ⭐ NOUVEAU : ID de l'ami concerné
  @Column('uuid', { nullable: true })
  linkedFriendId: string;

  @Column({ nullable: true })
  proofImageUrl: string;

  @Column({ type: 'timestamp', nullable: true })
  repaymentRequestedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  settledAt: Date;

  @Column({ nullable: true })
  disputeReason: string;

  @Column({ type: 'timestamp', nullable: true })
  repaymentDeadline: Date;

  @Column({ default: false })
  deadlineNotificationSent: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}