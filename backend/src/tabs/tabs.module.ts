
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TabsController } from './tabs.controller';
import { TabsService } from './tabs.service';
import { TabEntity } from './entities/tab.entity';

@Module({
  imports: [TypeOrmModule.forFeature([TabEntity])],
  controllers: [TabsController],
  providers: [TabsService],
  exports: [TabsService],
})
export class TabsModule {}