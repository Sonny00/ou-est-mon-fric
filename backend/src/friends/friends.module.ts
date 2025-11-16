// backend/src/friends/friends.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FriendsController } from './friends.controller';
import { FriendsService } from './friends.service';
import { FriendEntity } from './entities/friend.entity';
import { TabEntity } from '../tabs/entities/tab.entity';
import { User } from '../users/entities/user.entity'; // ⭐ AJOUTER CET IMPORT

@Module({
  imports: [
    TypeOrmModule.forFeature([
      FriendEntity,
      TabEntity,
      User, // ⭐ AJOUTER CETTE LIGNE
    ]),
  ],
  controllers: [FriendsController],
  providers: [FriendsService],
  exports: [FriendsService],
})
export class FriendsModule {}