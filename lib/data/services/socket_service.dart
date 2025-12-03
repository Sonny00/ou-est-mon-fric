// lib/data/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/friends/providers/friends_provider.dart';
import '../../features/tabs/providers/tabs_provider.dart'; // ⭐ AJOUTER

class SocketService {
  IO.Socket? socket;
  final Ref ref;
  
  SocketService(this.ref);
  
  void connect(String userId, String token) {
    if (socket != null && socket!.connected) {
      print('⚠️ WebSocket: Already connected');
      return;
    }

    const serverUrl = 'http://localhost:3000';

    print('🔌 WebSocket: Tentative de connexion à $serverUrl');
    print('   userId: $userId');

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'userId': userId, 'token': token})
        .setTimeout(5000)
        .build(),
    );
    
    socket?.onConnect((_) {
      print('✅ WebSocket: Connected successfully!');
    });
    
    socket?.onDisconnect((reason) {
      print('❌ WebSocket: Disconnected - Reason: $reason');
    });
    
    socket?.onConnectError((error) {
      print('❌ WebSocket: Connection error: $error');
    });
    
    socket?.onError((error) {
      print('❌ WebSocket: Error: $error');
    });
    
    // ==================== ÉVÉNEMENTS AMIS ====================
    
    // ⭐ Invitation reçue
    socket?.on('friend_request_received', (data) {
      print('📥 WebSocket: Nouvelle invitation reçue: $data');
      ref.invalidate(receivedRequestsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(receivedRequestsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Invitation acceptée
    socket?.on('friend_request_accepted', (data) {
      print('✅ WebSocket: Invitation acceptée: $data');
      ref.invalidate(friendsProvider);
      ref.invalidate(sentRequestsProvider);
      
      Future.delayed(const Duration(milliseconds: 800), () {
        try {
          ref.read(friendsProvider.future);
          ref.read(sentRequestsProvider.future);
        } catch (_) {}
      });
    });

    // ⭐ Ami supprimé
    socket?.on('friend_deleted', (data) {
      print('🗑️ WebSocket: Ami supprimé: $data');
      ref.invalidate(friendsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(friendsProvider.future);
        } catch (_) {}
      });
    });

    // ==================== ÉVÉNEMENTS TABS ====================
    
    // ⭐ Nouveau tab créé (reçu en tant que creditor ou debtor)
    socket?.on('tab_created', (data) {
      print('📝 WebSocket: Nouveau tab créé: $data');
      ref.invalidate(tabsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(tabsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Tab modifié
    socket?.on('tab_updated', (data) {
      print('✏️ WebSocket: Tab modifié: $data');
      ref.invalidate(tabsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(tabsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Tab supprimé
    socket?.on('tab_deleted', (data) {
      print('🗑️ WebSocket: Tab supprimé: $data');
      ref.invalidate(tabsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(tabsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Demande de synchronisation reçue
    socket?.on('sync_request_received', (data) {
      print('🔔 WebSocket: Nouvelle demande de synchronisation: $data');
      ref.invalidate(pendingSyncRequestsProvider);
      ref.invalidate(tabsProvider); // ⭐ Rafraîchir aussi les tabs
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(pendingSyncRequestsProvider.future);
          ref.read(tabsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Demande de synchronisation acceptée
    socket?.on('sync_request_accepted', (data) {
      print('✅ WebSocket: Demande de synchronisation acceptée: $data');
      ref.invalidate(tabsProvider);
      ref.invalidate(pendingSyncRequestsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(tabsProvider.future);
          ref.read(pendingSyncRequestsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Demande de synchronisation refusée
    socket?.on('sync_request_rejected', (data) {
      print('❌ WebSocket: Demande de synchronisation refusée: $data');
      ref.invalidate(pendingSyncRequestsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(pendingSyncRequestsProvider.future);
        } catch (_) {}
      });
    });
    
    // ⭐ Remboursement déclaré
    socket?.on('repayment_declared', (data) {
      print('💰 WebSocket: Remboursement déclaré: $data');
      ref.invalidate(tabsProvider);
      ref.invalidate(pendingSyncRequestsProvider);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          ref.read(tabsProvider.future);
          ref.read(pendingSyncRequestsProvider.future);
        } catch (_) {}
      });
    });

    socket?.connect();
  }
  
  void disconnect() {
    if (socket != null) {
      socket?.disconnect();
      socket?.dispose();
      socket = null;
      print('🔌 WebSocket: Disconnected and disposed');
    }
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService(ref);
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});