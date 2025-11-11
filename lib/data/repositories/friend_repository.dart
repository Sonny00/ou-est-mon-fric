// lib/data/repositories/friend_repository.dart

import '../services/api_service.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final ApiService _apiService;
  
  FriendRepository(this._apiService);
  
  Future<List<Friend>> getFriends() async {
    try {
      final response = await _apiService.get('/friends');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Friend.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les amis: $e');
    }
  }
  
  Future<Friend> addFriend(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/friends', data: data);
      
      if (response['success'] == true) {
        return Friend.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible d\'ajouter l\'ami: $e');
    }
  }
  
  // ← CORRIGER CETTE MÉTHODE
  Future<void> deleteFriend(String id) async {
    try {
      print('🗑️ Repository: Tentative de suppression de $id');
      
      final response = await _apiService.delete('/friends/$id');
      
      print('📡 Réponse API: $response');
      
      // VÉRIFIER LA RÉPONSE
      if (response['success'] != true) {
        throw Exception('La suppression a échoué: ${response['message'] ?? 'Erreur inconnue'}');
      }
      
      print('✅ Repository: Ami supprimé avec succès');
    } catch (e) {
      print('❌ Repository: Erreur lors de la suppression: $e');
      throw Exception('Impossible de supprimer l\'ami: $e');
    }
  }
  
  Future<Friend> updateFriend(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch('/friends/$id', data: data);
      
      if (response['success'] == true) {
        return Friend.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de modifier l\'ami: $e');
    }
  }
}