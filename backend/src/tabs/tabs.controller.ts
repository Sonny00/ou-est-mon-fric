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
@UseGuards(JwtAuthGuard)
export class TabsController {
  constructor(private readonly tabsService: TabsService) {}

  // ========== ROUTES DE BASE ==========

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
      message: 'Tab créé avec succès',
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
      message: 'Tab mis à jour',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id') id: string, @CurrentUser() user: any) {
    const data = await this.tabsService.remove(id, user.id);
    return {
      success: true,
      data,
      message: 'Tab supprimé',
    };
  }

  // ========== NOUVELLES ROUTES DE SYNCHRONISATION ==========

  /**
   * ⭐ Récupérer les demandes de synchronisation en attente
   * GET /tabs/sync/pending
   */
  @Get('sync/pending')
  async getPendingSyncRequests(@CurrentUser() user: any) {
    const data = await this.tabsService.getPendingSyncRequests(user.id);
    return {
      success: true,
      data,
    };
  }

  /**
   * ⭐ Répondre à une demande de synchronisation
   * POST /tabs/sync/:id/respond
   * Body: { action: 'accept' | 'reject', rejectionReason?: string }
   */
  @Post('sync/:id/respond')
  @HttpCode(HttpStatus.OK)
  async respondToSyncRequest(
    @Param('id') id: string,
    @Body() body: { action: 'accept' | 'reject'; rejectionReason?: string },
    @CurrentUser() user: any,
  ) {
    const data = await this.tabsService.respondToSyncRequest(
      user.id,
      id,
      body.action,
      body.rejectionReason,
    );
    return {
      success: true,
      data,
      message: body.action === 'accept' 
        ? 'Synchronisation acceptée' 
        : 'Synchronisation refusée',
    };
  }

  /**
   * ⭐ Déclarer un remboursement
   * POST /tabs/:id/repayment
   */
  @Post(':id/repayment')
  @HttpCode(HttpStatus.OK)
  async declareRepayment(
    @Param('id') id: string,
    @CurrentUser() user: any,
  ) {
    const data = await this.tabsService.declareRepayment(user.id, id);
    return {
      success: true,
      data,
      message: 'Demande de remboursement envoyée',
    };
  }
}