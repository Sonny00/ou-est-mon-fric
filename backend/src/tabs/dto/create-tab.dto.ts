import { IsString, IsNotEmpty, IsNumber, Min, IsOptional } from 'class-validator';

export class CreateTabDto {
  @IsString()
  @IsNotEmpty()
  creditorId: string;

  @IsString()
  @IsNotEmpty()
  creditorName: string;

  @IsString()
  @IsNotEmpty()
  debtorId: string;

  @IsString()
  @IsNotEmpty()
  debtorName: string;

  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsOptional()
  proofImageUrl?: string;
}
