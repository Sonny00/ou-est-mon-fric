// lib/data/repositories/activity_repository.dart

import '../services/api_service.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  final ApiService _apiService;
  
  ActivityRepository(this._apiService);
  
  // Pour l'instant, on génère les activités depuis les tabs
  // Plus tard, tu auras un vrai endpoint /activities
  Future<List<ActivityModel>> getActivities() async {
    try {
      // Récupérer les tabs pour générer les activités
      final response = await _apiService.get('/tabs');
      
      if (response['success'] == true) {
        final List<dynamic> tabsData = response['data'];
        
        // Convertir les tabs en activités
        final activities = <ActivityModel>[];
        
        for (var tabJson in tabsData) {
          activities.add(ActivityModel(
            id: tabJson['id'],
            type: ActivityType.tabCreated,
            title: 'Tab créée',
            description: '${tabJson['creditorName']} → ${tabJson['debtorName']}: ${tabJson['amount']}€',
            createdAt: DateTime.parse(tabJson['createdAt']),
            metadata: tabJson,
          ));
        }
        
        // Trier par date décroissante
        activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return activities;
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Impossible de charger les activités: $e');
    }
  }
}