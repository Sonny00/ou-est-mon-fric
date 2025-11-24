// backend/src/tabs/tabs.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TabsController } from './tabs.controller';
import { TabsService } from './tabs.service';
import { TabEntity } from './entities/tab.entity';
import { TabSyncRequestEntity } from './entities/tab-sync-request.entity'; // ⭐ AJOUTER
import { FriendEntity } from '../friends/entities/friend.entity';
import { User } from '../users/entities/user.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      TabEntity,
      TabSyncRequestEntity, // ⭐ AJOUTER ICI
      FriendEntity,
      User,
    ]),
    forwardRef(() => NotificationsModule),
  ],
  controllers: [TabsController],
  providers: [TabsService],
  exports: [TabsService],
})
export class TabsModule {}