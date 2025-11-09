// backend/src/auth/auth.controller.ts

import { Controller, Post, Body, Get, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    console.log('📝 Register endpoint hit'); // Debug
    const result = await this.authService.register(registerDto);
    return {
      success: true,
      ...result,
    };
  }

  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    console.log('🔐 Login endpoint hit'); // Debug
    const result = await this.authService.login(loginDto);
    return {
      success: true,
      ...result,
    };
  }

  @Post('google')
  async googleAuth(@Body() body: any) {
    console.log('🔵 Google auth endpoint hit'); // Debug
    const result = await this.authService.googleLogin(body);
    return {
      success: true,
      ...result,
    };
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser() user: any) {
    console.log('👤 Get me endpoint hit for user:', user.id); // Debug
    return {
      success: true,
      data: await this.authService.getMe(user.id),
    };
  }
}