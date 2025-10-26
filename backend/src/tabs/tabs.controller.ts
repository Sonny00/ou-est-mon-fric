// src/tabs/tabs.controller.ts

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
import { TabsService } from './tabs.service';
import { CreateTabDto } from './dto/create-tab.dto';
import { UpdateTabDto } from './dto/update-tab.dto';

@Controller('tabs')
export class TabsController {
  constructor(private readonly tabsService: TabsService) {}

  @Get()
  async findAll() {
    const data = await this.tabsService.findAll();
    return {
      success: true,
      data,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const data = await this.tabsService.findOne(id);
    return {
      success: true,
      data,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createTabDto: CreateTabDto) {
    const data = await this.tabsService.create(createTabDto);
    return {
      success: true,
      data,
      message: 'Tab created successfully',
    };
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateTabDto: UpdateTabDto) {
    const data = await this.tabsService.update(id, updateTabDto);
    return {
      success: true,
      data,
      message: 'Tab updated successfully',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string) {
    const data = await this.tabsService.remove(id);
    return {
      success: true,
      data,
    };
  }

  @Post(':id/confirm')
  @HttpCode(HttpStatus.OK)
  async confirmTab(@Param('id') id: string) {
    const data = await this.tabsService.confirmTab(id);
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
    @Body('proofImageUrl') proofImageUrl?: string,
  ) {
    const data = await this.tabsService.requestRepayment(id, proofImageUrl);
    return {
      success: true,
      data,
      message: 'Repayment requested',
    };
  }

  @Post(':id/confirm-repayment')
  @HttpCode(HttpStatus.OK)
  async confirmRepayment(@Param('id') id: string) {
    const data = await this.tabsService.confirmRepayment(id);
    return {
      success: true,
      data,
      message: 'Repayment confirmed',
    };
  }
}