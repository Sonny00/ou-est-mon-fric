// backend/src/tabs/entities/tab-sync-request.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

export enum SyncRequestType {
  CREATE = 'create',      // Nouvelle tab créée
  UPDATE = 'update',      // Tab modifiée
  DELETE = 'delete',      // Tab supprimée
  REPAYMENT = 'repayment', // Remboursement effectué
}

export enum SyncRequestStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
}

@Entity('tab_sync_requests')
export class TabSyncRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: SyncRequestType,
  })
  type: SyncRequestType;

  @Column('uuid')
  initiatedBy: string;

  @Column()
  initiatedByName: string;

  @Column('uuid')
  targetUserId: string;

  @Column('uuid')
  initiatorTabId: string;

  @Column('uuid', { nullable: true })
  targetTabId: string;

  @Column({ type: 'jsonb', nullable: true })
  tabData: {
    description: string;
    amount: number;
    creditorId: string;
    creditorName: string;
    debtorId: string;
    debtorName: string;
  };

  @Column({ type: 'text', nullable: true })
  message: string;

  @Column({
    type: 'enum',
    enum: SyncRequestStatus,
    default: SyncRequestStatus.PENDING,
  })
  status: SyncRequestStatus;

  @Column({ type: 'text', nullable: true })
  rejectionReason: string;

  @CreateDateColumn()
  createdAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  respondedAt: Date;
}