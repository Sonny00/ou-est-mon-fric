// backend/src/tabs/dto/update-tab.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreateTabDto } from './create-tab.dto';
import { IsEnum, IsOptional, IsDateString, IsString } from 'class-validator';

export class UpdateTabDto extends PartialType(CreateTabDto) {
  @IsEnum(['pending', 'confirmed', 'repayment_requested', 'settled', 'disputed'])
  @IsOptional()
  status?: string;

  @IsDateString()
  @IsOptional()
  repaymentRequestedAt?: Date;

  @IsDateString()
  @IsOptional()
  settledAt?: Date;

  @IsString()
  @IsOptional()
  proofImageUrl?: string;

  // ========== AJOUTER CETTE LIGNE ==========
  @IsDateString()
  @IsOptional()
  repaymentDeadline?: string;
  // =========================================
}