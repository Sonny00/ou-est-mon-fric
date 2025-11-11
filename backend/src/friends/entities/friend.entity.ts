import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, OneToMany } from 'typeorm';
import { TabEntity } from '../../tabs/entities/tab.entity'; // ← Importer TabEntity

@Entity('friends')
export class FriendEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  phoneNumber: string;

  @Column({ nullable: true })
  email: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @CreateDateColumn()
  addedAt: Date;

  @OneToMany(() => TabEntity, (tab) => tab.debtor, {
    cascade: true,
    onDelete: 'CASCADE',
  })
  tabsAsDebtor: TabEntity[];

  @OneToMany(() => TabEntity, (tab) => tab.creditor, {
    cascade: true,
    onDelete: 'CASCADE',
  })
  tabsAsCreditor: TabEntity[];
}