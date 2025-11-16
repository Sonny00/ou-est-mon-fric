// lib/data/repositories/friend_repository.dart

import '../services/api_service.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final ApiService _apiService;
  
  FriendRepository(this._apiService);
  
  // ========== MÉTHODES EXISTANTES ==========
  
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
  
  Future<Friend> createFriend(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/friends', data: data);
      
      if (response['success'] == true) {
        return Friend.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de créer l\'ami: $e');
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
  
  Future<void> deleteFriend(String id) async {
    try {
      await _apiService.delete('/friends/$id');
    } catch (e) {
      throw Exception('Impossible de supprimer l\'ami: $e');
    }
  }
  
  // ========== ⭐ NOUVELLES MÉTHODES POUR AMIS VÉRIFIÉS ==========
  
  /// Envoyer une invitation d'ami vérifié par TAG
  Future<Map<String, dynamic>> sendFriendRequestByTag(String tag) async {
    try {
      final response = await _apiService.post(
        '/friends/requests/send',
        data: {'tag': tag}, // ⭐ Changé de "email" à "tag"
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible d\'envoyer l\'invitation: $e');
    }
  }
  
  /// Récupérer les invitations reçues
  Future<List<Friend>> getReceivedRequests() async {
    try {
      final response = await _apiService.get('/friends/requests/received');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Friend.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les invitations: $e');
    }
  }
  
  /// Récupérer les invitations envoyées
  Future<List<Friend>> getSentRequests() async {
    try {
      final response = await _apiService.get('/friends/requests/sent');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Friend.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les invitations: $e');
    }
  }
  
  /// Accepter ou refuser une invitation
  Future<Friend?> respondToRequest(String friendId, String response) async {
    try {
      final result = await _apiService.post(
        '/friends/requests/$friendId/respond',
        data: {'response': response}, // "accept" ou "reject"
      );
      
      if (result['success'] == true) {
        if (result['data'] != null) {
          return Friend.fromJson(result['data']);
        }
        return null; // Cas du refus
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de répondre à l\'invitation: $e');
    }
  }
  
  /// Annuler une invitation envoyée
  Future<void> cancelRequest(String friendId) async {
    try {
      await _apiService.delete('/friends/requests/$friendId/cancel');
    } catch (e) {
      throw Exception('Impossible d\'annuler l\'invitation: $e');
    }
  }
}