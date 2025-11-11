// backend/src/friends/friends.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FriendsService } from './friends.service';
import { FriendsController } from './friends.controller';
import { FriendEntity } from './entities/friend.entity';
import { TabEntity } from '../tabs/entities/tab.entity'; // ← Import

@Module({
  imports: [
    TypeOrmModule.forFeature([FriendEntity, TabEntity]), // ← Ajouter TabEntity
  ],
  controllers: [FriendsController],
  providers: [FriendsService],
  exports: [FriendsService],
})
export class FriendsModule {}