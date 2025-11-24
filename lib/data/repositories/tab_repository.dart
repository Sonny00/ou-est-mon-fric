// lib/data/repositories/tab_repository.dart

import '../services/api_service.dart';
import '../models/tab_model.dart';
import '../models/tab_sync_request_model.dart';

class TabRepository {
  final ApiService _apiService;
  
  TabRepository(this._apiService);
  
  Future<List<TabModel>> getTabs() async {
    try {
      final response = await _apiService.get('/tabs');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TabModel.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les tabs: $e');
    }
  }
  
  Future<TabModel> getTabById(String id) async {
    try {
      final response = await _apiService.get('/tabs/$id');
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger la tab: $e');
    }
  }
  
  Future<TabModel> createTab(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/tabs', data: data);
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de créer la tab: $e');
    }
  }
  
  Future<TabModel> updateTab(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/tabs/$id', data: data);
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de modifier la tab: $e');
    }
  }
  
  Future<void> deleteTab(String id) async {
    try {
      await _apiService.delete('/tabs/$id');
    } catch (e) {
      throw Exception('Impossible de supprimer la tab: $e');
    }
  }

  // ⭐ NOUVEAU : Déclarer un remboursement
  Future<TabSyncRequest> declareRepayment(String tabId) async {
    try {
      final response = await _apiService.post('/tabs/$tabId/repayment');
      
      if (response['success'] == true) {
        return TabSyncRequest.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de déclarer le remboursement: $e');
    }
  }

  // ⭐ NOUVEAU : Récupérer les demandes de synchro en attente
  Future<List<TabSyncRequest>> getPendingSyncRequests() async {
    try {
      final response = await _apiService.get('/tabs/sync/pending');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TabSyncRequest.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les demandes: $e');
    }
  }

  // ⭐ NOUVEAU : Répondre à une demande de synchro
  Future<TabSyncRequest> respondToSyncRequest(
    String syncRequestId,
    String action, {
    String? rejectionReason,
  }) async {
    try {
      final response = await _apiService.post(
        '/tabs/sync/$syncRequestId/respond',
        data: {
          'action': action,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      
      if (response['success'] == true) {
        return TabSyncRequest.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de répondre à la demande: $e');
    }
  }
}