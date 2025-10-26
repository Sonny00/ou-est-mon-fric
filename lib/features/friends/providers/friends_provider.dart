// lib/features/friends/providers/friends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/services/api_service.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FriendRepository(apiService);
});

final friendsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
});

// Provider global pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});