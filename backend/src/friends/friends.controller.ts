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
import { SendFriendRequestDto } from './dto/send-friend-request.dto';
import { RespondFriendRequestDto } from './dto/respond-friend-request.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('friends')
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Get()
  async findAll(@CurrentUser() user: any) {
    console.log('👤 User:', user);
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

  /**
   * ⭐ Envoyer une invitation par TAG
   * POST /friends/requests/send
   * Body: { tag: "Sonny#7842" }
   */
  @Post('requests/send')
  @HttpCode(HttpStatus.CREATED)
  async sendFriendRequest(
    @Body() dto: SendFriendRequestDto,
    @CurrentUser() user: any,
  ) {
    const data = await this.friendsService.sendFriendRequest(user.id, dto);
    return {
      success: true,
      data,
      message: 'Friend request sent successfully',
    };
  }

  /**
   * Récupérer les invitations reçues
   */
  @Get('requests/received')
  async getReceivedRequests(@CurrentUser() user: any) {
    const data = await this.friendsService.getReceivedRequests(user.id);
    return {
      success: true,
      data,
    };
  }

  /**
   * Récupérer les invitations envoyées
   */
  @Get('requests/sent')
  async getSentRequests(@CurrentUser() user: any) {
    const data = await this.friendsService.getSentRequests(user.id);
    return {
      success: true,
      data,
    };
  }

  /**
   * Accepter ou refuser une invitation
   * POST /friends/requests/:id/respond
   * Body: { response: "accept" | "reject" }
   */
  @Post('requests/:id/respond')
  @HttpCode(HttpStatus.OK)
  async respondToRequest(
    @Param('id') id: string,
    @Body() dto: RespondFriendRequestDto,
    @CurrentUser() user: any,
  ) {
    const data = await this.friendsService.respondToRequest(user.id, id, dto.response);
    return {
      success: true,
      data,
      message: dto.response === 'accept' 
        ? 'Friend request accepted' 
        : 'Friend request rejected',
    };
  }

  /**
   * Annuler une invitation envoyée
   */
  @Delete('requests/:id/cancel')
  @HttpCode(HttpStatus.OK)
  async cancelRequest(@Param('id') id: string, @CurrentUser() user: any) {
    await this.friendsService.cancelRequest(user.id, id);
    return {
      success: true,
      message: 'Friend request cancelled successfully',
      };
  }
}