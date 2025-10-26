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
