// lib/features/friends/providers/friends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/services/api_service.dart';
import '../../activity/providers/activity_provider.dart'; // ← AJOUTER CET IMPORT

// Provider global pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider du repository
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FriendRepository(apiService);
});

// FutureProvider (garde pour compatibilité)
final friendsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getFriends();
});

// ✅ STATENOTIFIER (COMME TABS)
final friendsNotifierProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  return FriendsNotifier(ref);
});

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  final Ref ref;
  
  FriendsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadFriends();
  }
  
  Future<void> loadFriends() async {
    state = const AsyncValue.loading();
    try {
      print('🔄 FriendsNotifier: Chargement des amis...');
      final repository = ref.read(friendRepositoryProvider);
      final friends = await repository.getFriends();
      state = AsyncValue.data(friends);
      print('✅ FriendsNotifier: ${friends.length} ami(s) chargé(s)');
    } catch (e, stack) {
      print('❌ FriendsNotifier: Erreur de chargement: $e');
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addFriend(Map<String, dynamic> data) async {
    try {
      print('➕ FriendsNotifier: Ajout d\'un ami...');
      final repository = ref.read(friendRepositoryProvider);
      await repository.addFriend(data);
      print('✅ FriendsNotifier: Ami ajouté, rechargement...');
      await loadFriends();
      ref.invalidate(activityProvider); // ← AJOUTER
    } catch (e) {
      print('❌ FriendsNotifier: Erreur d\'ajout: $e');
      rethrow;
    }
  }
  
  Future<void> deleteFriend(String id) async {
    try {
      print('🗑️ FriendsNotifier: Suppression de $id');
      final repository = ref.read(friendRepositoryProvider);
      await repository.deleteFriend(id);
      print('✅ FriendsNotifier: Ami supprimé, rechargement...');
      await loadFriends();
      ref.invalidate(activityProvider); // ← AJOUTER
      print('✅ FriendsNotifier: Liste rechargée !');
    } catch (e) {
      print('❌ FriendsNotifier: Erreur de suppression: $e');
      rethrow;
    }
  }
  
  Future<void> updateFriend(String id, Map<String, dynamic> data) async {
    try {
      print('✏️ FriendsNotifier: Modification de $id');
      final repository = ref.read(friendRepositoryProvider);
      await repository.updateFriend(id, data);
      print('✅ FriendsNotifier: Ami modifié, rechargement...');
      await loadFriends();
      ref.invalidate(activityProvider); // ← AJOUTER
    } catch (e) {
      print('❌ FriendsNotifier: Erreur de modification: $e');
      rethrow;
    }
  }
}