// backend/src/friends/entities/friend.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum FriendStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  BLOCKED = 'blocked',
}

@Entity('friends')
export class FriendEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // ⭐ Ami vérifié (a un compte)
  @Column('uuid', { nullable: true })
  friendUserId: string | null;

  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'friendUserId' })
  friendUser: User | null;

  // ⭐ Ami non-vérifié (pas de compte)
  @Column()
  name: string;

  @Column({ nullable: true })
  phoneNumber: string;

  @Column({ nullable: true })
  email: string;

  @Column({ nullable: true })
  avatarUrl: string;

  // ⭐ NOUVEAU : Statut de la relation
  @Column({
    type: 'enum',
    enum: FriendStatus,
    default: FriendStatus.ACCEPTED,
  })
  status: FriendStatus;

  // ⭐ NOUVEAU : Type d'ami
  @Column({ default: false })
  isVerified: boolean;

  @CreateDateColumn()
  addedAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}