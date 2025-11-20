// lib/features/friends/providers/friends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FriendRepository(apiService);
});

// ========== PROVIDERS POUR LES DONNÉES ==========

final friendsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
});

final receivedRequestsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getReceivedRequests();
});

final sentRequestsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getSentRequests();
});

// ========== STATE NOTIFIER POUR LES ACTIONS ==========

class FriendsNotifier extends StateNotifier<AsyncValue<void>> {
  FriendsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final FriendRepository _repository;
  final Ref _ref;
  
  Future<void> createFriend(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createFriend(data);
      _ref.invalidate(friendsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> updateFriend(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateFriend(id, data);
      _ref.invalidate(friendsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> deleteFriend(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteFriend(id);
      
      _ref.invalidate(friendsProvider);
      
      // ⭐ Attendre puis forcer le rechargement
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _ref.read(friendsProvider.future);
      } catch (_) {
        // Ignorer les erreurs de rechargement
      }
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> sendFriendRequestByTag(String tag) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendFriendRequestByTag(tag);
      _ref.invalidate(sentRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> acceptRequest(String friendId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.respondToRequest(friendId, 'accept');
      
      _ref.invalidate(friendsProvider);
      _ref.invalidate(receivedRequestsProvider);
      _ref.invalidate(sentRequestsProvider);
      
      // ⭐ Attendre puis forcer le rechargement
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _ref.read(friendsProvider.future);
      } catch (_) {
        // Ignorer les erreurs de rechargement
      }
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> rejectRequest(String friendId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.respondToRequest(friendId, 'reject');
      _ref.invalidate(receivedRequestsProvider);
      _ref.invalidate(sentRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> cancelRequest(String friendId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelRequest(friendId);
      _ref.invalidate(sentRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final friendsNotifierProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return FriendsNotifier(repository, ref);
});