// backend/src/notifications/notifications.gateway.ts

import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ 
  cors: {
    origin: '*',
    credentials: true,
  }
})
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private userSockets = new Map<string, string>();

  handleConnection(client: Socket) {
    const userId = client.handshake.auth.userId;
    console.log('🔌 WebSocket: Client attempting connection');
    console.log('   Auth data:', client.handshake.auth);
    
    if (userId) {
      this.userSockets.set(userId, client.id);
      console.log(`✅ WebSocket: User ${userId} connected (socket: ${client.id})`);
    } else {
      console.log(`⚠️ WebSocket: Client ${client.id} connected without userId`);
    }
  }

  handleDisconnect(client: Socket) {
    const userId = [...this.userSockets.entries()]
      .find(([_, socketId]) => socketId === client.id)?.[0];
    if (userId) {
      this.userSockets.delete(userId);
      console.log(`❌ WebSocket: User ${userId} disconnected`);
    }
  }

  sendToUser(userId: string, event: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit(event, data);
      console.log(`📤 WebSocket: Notification envoyée à ${userId}: ${event}`);
    } else {
      console.log(`⚠️ WebSocket: User ${userId} not connected`);
    }
  }
}