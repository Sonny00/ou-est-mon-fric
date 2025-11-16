// backend/src/users/entities/user.entity.ts

import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index, // ⭐ AJOUTER
} from 'typeorm';
import { Exclude } from 'class-transformer';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, nullable: true })
  email: string;

  @Column({ unique: true, nullable: true })
  phoneNumber: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  @Exclude()
  password: string;

  @Column({ nullable: true })
  avatarUrl: string;

  // Google OAuth
  @Column({ nullable: true })
  googleId: string;

  @Column({ default: false })
  isEmailVerified: boolean;

  // ⭐ NOUVEAU : Tag unique
  @Column({ unique: true, nullable: true })
  @Index() // Pour optimiser les recherches
  tag: string; // Ex: "Sonny#7842"

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}