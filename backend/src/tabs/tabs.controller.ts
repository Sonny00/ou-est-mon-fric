// backend/src/tabs/tabs.controller.ts

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
import { TabsService } from './tabs.service';
import { CreateTabDto } from './dto/create-tab.dto';
import { UpdateTabDto } from './dto/update-tab.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('tabs')
@UseGuards(JwtAuthGuard) // ← Protéger toutes les routes
export class TabsController {
  constructor(private readonly tabsService: TabsService) {}

  @Get()
  async findAll(@CurrentUser() user: any) {
    const data = await this.tabsService.findAllByUser(user.id);
    return {
      success: true,
      data,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.tabsService.findOne(id, user.id);
    return {
      success: true,
      data,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createTabDto: CreateTabDto, @CurrentUser() user: any) {
    const data = await this.tabsService.create(createTabDto, user.id);
    return {
      success: true,
      data,
      message: 'Tab created successfully',
    };
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateTabDto: UpdateTabDto,
    @CurrentUser() user: any,
  ) {
    const data = await this.tabsService.update(id, updateTabDto, user.id);
    return {
      success: true,
      data,
      message: 'Tab updated successfully',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.tabsService.remove(id, user.id);
    return {
      success: true,
      data,
    };
  }

  @Post(':id/confirm')
  @HttpCode(HttpStatus.OK)
  async confirmTab(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.tabsService.confirmTab(id, user.id);
    return {
      success: true,
      data,
      message: 'Tab confirmed',
    };
  }

  @Post(':id/request-repayment')
  @HttpCode(HttpStatus.OK)
  async requestRepayment(
    @Param('id') id: string,
    @Body('proofImageUrl') proofImageUrl: string | undefined,
    @CurrentUser() user: any,
  ) {
    const data = await this.tabsService.requestRepayment(id, user.id, proofImageUrl);
    return {
      success: true,
      data,
      message: 'Repayment requested',
    };
  }

  @Post(':id/confirm-repayment')
  @HttpCode(HttpStatus.OK)
  async confirmRepayment(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.tabsService.confirmRepayment(id, user.id);
    return {
      success: true,
      data,
      message: 'Repayment confirmed',
    };
  }
}