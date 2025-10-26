// lib/data/repositories/friend_repository.dart

import '../services/api_service.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final ApiService _apiService;
  
  FriendRepository(this._apiService);
  
  // Pour l'instant, retourne une liste vide
  // Plus tard, tu auras un vrai endpoint /friends
  Future<List<Friend>> getFriends() async {
    try {
      // TODO: Implémenter quand le backend aura /friends
      // final response = await _apiService.get('/friends');
      
      // Pour l'instant, retourne vide
      return [];
    } catch (e) {
      throw Exception('Impossible de charger les amis: $e');
    }
  }
  
  Future<Friend> addFriend(Map<String, dynamic> data) async {
    try {
      // TODO: Implémenter quand le backend aura POST /friends
      // final response = await _apiService.post('/friends', data: data);
      
      throw UnimplementedError('API /friends pas encore implémentée');
    } catch (e) {
      throw Exception('Impossible d\'ajouter l\'ami: $e');
    }
  }
  
  Future<void> deleteFriend(String id) async {
    try {
      // TODO: Implémenter quand le backend aura DELETE /friends/:id
      throw UnimplementedError('API /friends pas encore implémentée');
    } catch (e) {
      throw Exception('Impossible de supprimer l\'ami: $e');
    }
  }
}