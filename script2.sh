#!/bin/bash

# Script de création du module Friends
# Usage: chmod +x create-friends-module.sh && ./create-friends-module.sh

echo "🚀 Création du module Friends..."

# Naviguer vers le dossier backend
cd backend

# 1. Créer les dossiers
echo "📁 Création des dossiers..."
mkdir -p src/friends/dto
mkdir -p src/friends/entities

# 2. Créer Friend Entity
echo "📝 Création de friend.entity.ts..."
cat > src/friends/entities/friend.entity.ts << 'EOF'
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

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
}
EOF

# 3. Créer CreateFriendDto
echo "📝 Création de create-friend.dto.ts..."
cat > src/friends/dto/create-friend.dto.ts << 'EOF'
import { IsString, IsNotEmpty, IsOptional, IsEmail } from 'class-validator';

export class CreateFriendDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  avatarUrl?: string;
}
EOF

# 4. Créer UpdateFriendDto
echo "📝 Création de update-friend.dto.ts..."
cat > src/friends/dto/update-friend.dto.ts << 'EOF'
import { IsString, IsOptional, IsEmail } from 'class-validator';

export class UpdateFriendDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  avatarUrl?: string;
}
EOF

# 5. Créer Friends Controller
echo "📝 Création de friends.controller.ts..."
cat > src/friends/friends.controller.ts << 'EOF'
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FriendsService } from './friends.service';
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';

@Controller('friends')
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Get()
  async findAll() {
    const data = await this.friendsService.findAll();
    return {
      success: true,
      data,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const data = await this.friendsService.findOne(id);
    return {
      success: true,
      data,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createFriendDto: CreateFriendDto) {
    const data = await this.friendsService.create(createFriendDto);
    return {
      success: true,
      data,
      message: 'Friend added successfully',
    };
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateFriendDto: UpdateFriendDto) {
    const data = await this.friendsService.update(id, updateFriendDto);
    return {
      success: true,
      data,
      message: 'Friend updated successfully',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    const data = await this.friendsService.remove(id);
    return {
      success: true,
      data,
      message: 'Friend deleted successfully',
    };
  }
}
EOF

# 6. Créer Friends Service
echo "📝 Création de friends.service.ts..."
cat > src/friends/friends.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FriendEntity } from './entities/friend.entity';
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendEntity)
    private readonly friendRepository: Repository<FriendEntity>,
  ) {}

  async findAll(): Promise<FriendEntity[]> {
    return this.friendRepository.find({
      order: { addedAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<FriendEntity> {
    const friend = await this.friendRepository.findOne({ where: { id } });
    if (!friend) {
      throw new NotFoundException(`Friend with ID ${id} not found`);
    }
    return friend;
  }

  async create(createFriendDto: CreateFriendDto): Promise<FriendEntity> {
    const friend = this.friendRepository.create({
      ...createFriendDto,
      userId: 'current_user',
    });
    return this.friendRepository.save(friend);
  }

  async update(id: string, updateFriendDto: UpdateFriendDto): Promise<FriendEntity> {
    const friend = await this.findOne(id);
    Object.assign(friend, updateFriendDto);
    return this.friendRepository.save(friend);
  }

  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    const friend = await this.findOne(id);
    await this.friendRepository.remove(friend);
    return { deleted: true, message: 'Friend deleted successfully' };
  }
}
EOF

# 7. Créer Friends Module
echo "📝 Création de friends.module.ts..."
cat > src/friends/friends.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FriendsController } from './friends.controller';
import { FriendsService } from './friends.service';
import { FriendEntity } from './entities/friend.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FriendEntity])],
  controllers: [FriendsController],
  providers: [FriendsService],
  exports: [FriendsService],
})
export class FriendsModule {}
EOF

echo ""
echo "✅ Module Friends créé avec succès !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Ajoute FriendsModule dans app.module.ts (imports)"
echo "2. Lance: npm run start:dev"
echo ""