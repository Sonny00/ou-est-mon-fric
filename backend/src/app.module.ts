// src/app.module.ts

import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { TabsModule } from './tabs/tabs.module';
import { FriendsModule } from './friends/friends.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { use } from 'passport';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST || 'localhost',
      port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
      username: process.env.DATABASE_USER || 'postgres',
      password: process.env.DATABASE_PASSWORD || 'postgres',
      database: process.env.DATABASE_NAME || 'ouestmonfric',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true, 
      logging: true,
    }),
    TabsModule,
    FriendsModule,
    AuthModule,
    UsersModule,
    NotificationsModule,
    
  ],
  controllers: [AppController],
})
export class AppModule {}