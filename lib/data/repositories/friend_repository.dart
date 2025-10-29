// lib/data/repositories/friend_repository.dart

import '../services/api_service.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final ApiService _apiService;
  
  FriendRepository(this._apiService);
  
  // Récupérer tous les amis
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
  
  // Ajouter un ami
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
  
  // Supprimer un ami
  Future<void> deleteFriend(String id) async {
    try {
      await _apiService.delete('/friends/$id');
    } catch (e) {
      throw Exception('Impossible de supprimer l\'ami: $e');
    }
  }
  
  // Modifier un ami
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