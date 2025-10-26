import '../services/api_service.dart';
import '../models/tab_model.dart';

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
  
  Future<TabModel> confirmTab(String id) async {
    try {
      final response = await _apiService.post('/tabs/$id/confirm');
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de confirmer la tab: $e');
    }
  }
  
  Future<TabModel> requestRepayment(String id, {String? proofImageUrl}) async {
    try {
      final response = await _apiService.post(
        '/tabs/$id/request-repayment',
        data: {'proofImageUrl': proofImageUrl},
      );
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de demander le remboursement: $e');
    }
  }
  
  Future<TabModel> confirmRepayment(String id) async {
    try {
      final response = await _apiService.post('/tabs/$id/confirm-repayment');
      
      if (response['success'] == true) {
        return TabModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de confirmer le remboursement: $e');
    }
  }
}