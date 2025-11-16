// lib/data/repositories/user_repository.dart

import '../services/api_service.dart';
import '../models/user_stats_model.dart';

class UserRepository {
  final ApiService _apiService;
  
  UserRepository(this._apiService);
  
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await _apiService.get('/users/stats');
      
      if (response['success'] == true) {
        return UserStatsModel.fromJson(response['data']);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les stats: $e');
    }
  }
}
