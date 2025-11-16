// lib/features/profile/providers/user_stats_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_stats_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/api_service.dart';

// Provider pour ApiService (peut-être déjà existant ailleurs)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider pour UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserRepository(apiService);
});

// Provider pour les stats utilisateur
final userStatsProvider = FutureProvider.autoDispose<UserStatsModel>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserStats();
});
