// backend/src/tabs/entities/repayment.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

export enum RepaymentStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  REJECTED = 'rejected',
}

export enum RepaymentMethod {
  CASH = 'cash',
  BANK_TRANSFER = 'bank_transfer',
  MOBILE_PAYMENT = 'mobile_payment',
  PAYPAL = 'paypal',
  VENMO = 'venmo',
  OTHER = 'other',
}

@Entity('repayments')
export class RepaymentEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  tabId: string;

  @Column('decimal', {
    precision: 10,
    scale: 2,
    transformer: {
      to: (value: number) => value,
      from: (value: string) => parseFloat(value),
    },
  })
  amount: number;

  @Column('uuid')
  declaredBy: string;

  @Column()
  declaredByName: string;

  @Column('uuid')
  toBeConfirmedBy: string;

  @Column()
  toBeConfirmedByName: string;

  @Column({
    type: 'enum',
    enum: RepaymentStatus,
    default: RepaymentStatus.PENDING,
  })
  status: RepaymentStatus;

  @Column({
    type: 'enum',
    enum: RepaymentMethod,
    nullable: true,
  })
  method: RepaymentMethod;

  @Column({ type: 'text', nullable: true })
  note: string;

  @Column({ nullable: true })
  proofImageUrl: string;

  @Column({ type: 'text', nullable: true })
  rejectionReason: string;

  @Column({ type: 'timestamp', nullable: true })
  confirmedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}