// lib/features/friends/providers/friends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/services/api_service.dart';

// Provider pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider pour FriendRepository
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FriendRepository(apiService);
});

// ========== PROVIDERS POUR LES DONNÉES ==========

// Provider pour la liste des amis
final friendsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
});

// Provider pour les invitations reçues
final receivedRequestsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getReceivedRequests();
});

// Provider pour les invitations envoyées
final sentRequestsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getSentRequests();
});

// ========== STATE NOTIFIER POUR LES ACTIONS ==========

class FriendsNotifier extends StateNotifier<AsyncValue<void>> {
  FriendsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final FriendRepository _repository;
  final Ref _ref;
  
  // ⭐ Créer un ami non-vérifié
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
  
  // ⭐ Modifier un ami
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
  
  // ⭐ Supprimer un ami
  Future<void> deleteFriend(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteFriend(id);
      _ref.invalidate(friendsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  // ⭐ Envoyer une invitation d'ami vérifié PAR TAG
  Future<void> sendFriendRequestByTag(String tag) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendFriendRequestByTag(tag); // ⭐ CHANGÉ
      _ref.invalidate(friendsProvider);
      _ref.invalidate(sentRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  // ⭐ Accepter une invitation
  Future<void> acceptRequest(String friendId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.respondToRequest(friendId, 'accept');
      _ref.invalidate(friendsProvider);
      _ref.invalidate(receivedRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  // ⭐ Refuser une invitation
  Future<void> rejectRequest(String friendId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.respondToRequest(friendId, 'reject');
      _ref.invalidate(receivedRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  // ⭐ Annuler une invitation envoyée
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