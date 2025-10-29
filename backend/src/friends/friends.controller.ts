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
