// lib/features/activity/providers/activity_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/api_service.dart';

// Provider global pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ActivityRepository(apiService);
});

final activityProvider = FutureProvider.autoDispose<List<ActivityModel>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivities();
});