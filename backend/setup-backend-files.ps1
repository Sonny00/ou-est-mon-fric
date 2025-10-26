# setup-backend-files.ps1

Write-Host "Creation des fichiers Backend..." -ForegroundColor Green

function Create-File {
    param (
        [string]$Path,
        [string]$Content
    )
    
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    
    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "Cree: $Path" -ForegroundColor Cyan
}

$tabsController = @'
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
  findAll() {
    return {
      success: true,
      data: this.tabsService.findAll(),
    };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return {
      success: true,
      data: this.tabsService.findOne(id),
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createTabDto: CreateTabDto) {
    return {
      success: true,
      data: this.tabsService.create(createTabDto),
      message: 'Tab created successfully',
    };
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateTabDto: UpdateTabDto) {
    return {
      success: true,
      data: this.tabsService.update(id, updateTabDto),
      message: 'Tab updated successfully',
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id') id: string) {
    return {
      success: true,
      data: this.tabsService.remove(id),
    };
  }

  @Post(':id/confirm')
  @HttpCode(HttpStatus.OK)
  confirmTab(@Param('id') id: string) {
    return {
      success: true,
      data: this.tabsService.confirmTab(id),
      message: 'Tab confirmed',
    };
  }

  @Post(':id/request-repayment')
  @HttpCode(HttpStatus.OK)
  requestRepayment(
    @Param('id') id: string,
    @Body('proofImageUrl') proofImageUrl?: string,
  ) {
    return {
      success: true,
      data: this.tabsService.requestRepayment(id, proofImageUrl),
      message: 'Repayment requested',
    };
  }

  @Post(':id/confirm-repayment')
  @HttpCode(HttpStatus.OK)
  confirmRepayment(@Param('id') id: string) {
    return {
      success: true,
      data: this.tabsService.confirmRepayment(id),
      message: 'Repayment confirmed',
    };
  }
}
'@

Create-File -Path "src/tabs/tabs.controller.ts" -Content $tabsController

$tabsService = @'
import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateTabDto } from './dto/create-tab.dto';
import { UpdateTabDto } from './dto/update-tab.dto';

export enum TabStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  REPAYMENT_REQUESTED = 'repayment_requested',
  SETTLED = 'settled',
  DISPUTED = 'disputed',
}

interface Tab {
  id: string;
  creditorId: string;
  creditorName: string;
  debtorId: string;
  debtorName: string;
  amount: number;
  description: string;
  status: TabStatus;
  createdAt: Date;
  updatedAt: Date;
  proofImageUrl?: string;
  repaymentRequestedAt?: Date;
  settledAt?: Date;
}

@Injectable()
export class TabsService {
  private tabs: Tab[] = [
    {
      id: '1',
      creditorId: 'current_user',
      creditorName: 'Moi',
      debtorId: 'paul_123',
      debtorName: 'Paul',
      amount: 42.50,
      description: '🍕 Pizza vendredi soir',
      status: TabStatus.CONFIRMED,
      createdAt: new Date('2025-10-20'),
      updatedAt: new Date('2025-10-20'),
    },
    {
      id: '2',
      creditorId: 'marie_456',
      creditorName: 'Marie',
      debtorId: 'current_user',
      debtorName: 'Moi',
      amount: 23.00,
      description: '🎬 Ciné samedi',
      status: TabStatus.PENDING,
      createdAt: new Date('2025-10-23'),
      updatedAt: new Date('2025-10-23'),
    },
    {
      id: '3',
      creditorId: 'current_user',
      creditorName: 'Moi',
      debtorId: 'sophie_789',
      debtorName: 'Sophie',
      amount: 15.00,
      description: '☕ Café ce matin',
      status: TabStatus.CONFIRMED,
      createdAt: new Date('2025-10-26'),
      updatedAt: new Date('2025-10-26'),
    },
  ];

  findAll(): Tab[] {
    return this.tabs;
  }

  findOne(id: string): Tab {
    const tab = this.tabs.find(t => t.id === id);
    if (!tab) {
      throw new NotFoundException(`Tab with ID ${id} not found`);
    }
    return tab;
  }

  create(createTabDto: CreateTabDto): Tab {
    const newTab: Tab = {
      id: Date.now().toString(),
      ...createTabDto,
      status: TabStatus.PENDING,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this.tabs.push(newTab);
    return newTab;
  }

  update(id: string, updateTabDto: UpdateTabDto): Tab {
    const index = this.tabs.findIndex(t => t.id === id);
    if (index === -1) {
      throw new NotFoundException(`Tab with ID ${id} not found`);
    }
    
    this.tabs[index] = {
      ...this.tabs[index],
      ...updateTabDto,
      updatedAt: new Date(),
    };
    
    return this.tabs[index];
  }

  remove(id: string): { deleted: boolean; message: string } {
    const index = this.tabs.findIndex(t => t.id === id);
    if (index === -1) {
      throw new NotFoundException(`Tab with ID ${id} not found`);
    }
    
    this.tabs.splice(index, 1);
    return { deleted: true, message: 'Tab deleted successfully' };
  }

  confirmTab(id: string): Tab {
    const tab = this.findOne(id);
    return this.update(id, { status: TabStatus.CONFIRMED });
  }

  requestRepayment(id: string, proofImageUrl?: string): Tab {
    const tab = this.findOne(id);
    return this.update(id, {
      status: TabStatus.REPAYMENT_REQUESTED,
      repaymentRequestedAt: new Date(),
      proofImageUrl,
    });
  }

  confirmRepayment(id: string): Tab {
    const tab = this.findOne(id);
    return this.update(id, {
      status: TabStatus.SETTLED,
      settledAt: new Date(),
    });
  }
}
'@

Create-File -Path "src/tabs/tabs.service.ts" -Content $tabsService

$tabsModule = @'
import { Module } from '@nestjs/common';
import { TabsController } from './tabs.controller';
import { TabsService } from './tabs.service';

@Module({
  controllers: [TabsController],
  providers: [TabsService],
  exports: [TabsService],
})
export class TabsModule {}
'@

Create-File -Path "src/tabs/tabs.module.ts" -Content $tabsModule

$createTabDto = @'
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
'@

Create-File -Path "src/tabs/dto/create-tab.dto.ts" -Content $createTabDto

$updateTabDto = @'
import { PartialType } from '@nestjs/mapped-types';
import { CreateTabDto } from './create-tab.dto';
import { IsEnum, IsOptional, IsDateString } from 'class-validator';

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
}
'@

Create-File -Path "src/tabs/dto/update-tab.dto.ts" -Content $updateTabDto

$appModule = @'
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { TabsModule } from './tabs/tabs.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TabsModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
'@

Create-File -Path "src/app.module.ts" -Content $appModule

$mainTs = @'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'error', 'warn', 'debug', 'verbose'],
  });
  
  app.enableCors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });
  
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  
  app.setGlobalPrefix('api');
  
  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  
  console.log(`🚀 Backend running on: http://localhost:${port}`);
  console.log(`📚 API available at: http://localhost:${port}/api`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
}
bootstrap();
'@

Create-File -Path "src/main.ts" -Content $mainTs

$appController = @'
import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): any {
    return {
      message: 'Welcome to OuEstMonFric API',
      version: '1.0.0',
      status: 'running',
    };
  }

  @Get('health')
  healthCheck(): any {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
'@

Create-File -Path "src/app.controller.ts" -Content $appController

Write-Host ""
Write-Host "Fichiers crees avec succes!" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. npm install"
Write-Host "2. npm run start:dev"
Write-Host ""