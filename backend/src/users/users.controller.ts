// backend/src/users/users.controller.ts

import { Controller, Get, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('stats')
  async getUserStats(@CurrentUser() user: any) {
    const stats = await this.usersService.getUserStats(user.id);
    return {
      success: true,
      data: stats,
    };
  }

  @Get('profile')
  async getProfile(@CurrentUser() user: any) {
    const profile = await this.usersService.findById(user.id);
    return {
      success: true,
      data: profile,
    };
  }
}
