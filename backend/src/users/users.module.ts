// backend/src/users/users.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { TabEntity } from '../tabs/entities/tab.entity';
import { FriendEntity } from '../friends/entities/friend.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      TabEntity,
      FriendEntity,
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
