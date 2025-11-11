// backend/src/tabs/entities/tab.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { FriendEntity } from '../../friends/entities/friend.entity';

export enum TabStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  REPAYMENT_REQUESTED = 'repayment_requested',
  SETTLED = 'settled',
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

  // ✅ AJOUTER LES RELATIONS ICI
  @ManyToOne(() => FriendEntity, (friend) => friend.tabsAsCreditor, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'creditorId' })
  creditor: FriendEntity;

  @ManyToOne(() => FriendEntity, (friend) => friend.tabsAsDebtor, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'debtorId' })
  debtor: FriendEntity;
  // ✅ FIN DES RELATIONS

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

  @Column({ type: 'timestamp', nullable: true })
  repaymentDeadline: Date;

  @Column({ default: false })
  deadlineNotificationSent: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}