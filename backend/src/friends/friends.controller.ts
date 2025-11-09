// backend/src/friends/friends.controller.ts

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
  UseGuards,
} from '@nestjs/common';
import { FriendsService } from './friends.service';
import { CreateFriendDto } from './dto/create-friend.dto';
import { UpdateFriendDto } from './dto/update-friend.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('friends')
@UseGuards(JwtAuthGuard) // ← Protéger toutes les routes
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Get()
  async findAll(@CurrentUser() user: any) {
    console.log('👤 User:', user); // Debug
    const data = await this.friendsService.findAllByUser(user.id);
    return {
      success: true,
      data,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.friendsService.findOne(id, user.id);
    return {
      success: true,
      data,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createFriendDto: CreateFriendDto, @CurrentUser() user: any) {
    const data = await this.friendsService.create(createFriendDto, user.id);
    return {
      success: true,
      data,
      message: 'Friend added successfully',
    };
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateFriendDto: UpdateFriendDto,
    @CurrentUser() user: any,
  ) {
    const data = await this.friendsService.update(id, updateFriendDto, user.id);
    return {
      success: true,
      data,
      message: 'Friend updated successfully',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.friendsService.remove(id, user.id);
    return {
      success: true,
      data,
      message: 'Friend deleted successfully',
    };
  }
}