// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/token_storage.dart';
import '../../../data/services/socket_service.dart'; // ⭐ AJOUTER
import '../../tabs/providers/tabs_provider.dart';
import '../../friends/providers/friends_provider.dart';
import '../../activity/providers/activity_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    print('🔍 === VÉRIFICATION AUTH ===');
    
    try {
      final savedToken = await TokenStorage.getToken();
      final savedUser = await TokenStorage.getUser();
      
      print('Token en storage: ${savedToken != null ? "✅" : "❌"}');
      print('User en storage: ${savedUser != null ? "✅" : "❌"}');
      
      if (savedToken == null) {
        print('❌ Pas de token → Déconnecté');
        state = const AsyncValue.data(null);
        return;
      }

      print('✅ Token trouvé, vérification validité...');
      
      try {
        final user = await _repository.getMe();
        state = AsyncValue.data(user);
        print('✅ Token valide → Utilisateur connecté: ${user.name}');
        
        // ⭐ AJOUTER : Connecter WebSocket
        _ref.read(socketServiceProvider).connect(user.id, savedToken);
        
      } catch (e) {
        print('❌ Token invalide/expiré: $e');
        
        if (e.toString().contains('401') || e.toString().contains('Non autorisé')) {
          print('🗑️ Suppression du token invalide');
          await TokenStorage.deleteToken();
        }
        
        state = const AsyncValue.data(null);
      }
      
      print('=========================');
    } catch (e, st) {
      print('❌ Erreur checkAuth: $e');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      print('📝 AuthNotifier: Inscription en cours...');
      
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      
      final user = result['user'];
      final token = result['token'];
      state = AsyncValue.data(user);
      
      // ⭐ AJOUTER : Connecter WebSocket
      _ref.read(socketServiceProvider).connect(user.id, token);
      
      print('✅ AuthNotifier: Inscription réussie - ${user.name}');
    } catch (e, st) {
      print('❌ AuthNotifier: Erreur inscription - $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      print('🔐 AuthNotifier: Connexion en cours...');
      
      final result = await _repository.login(
        email: email,
        password: password,
      );
      
      final user = result['user'];
      final token = result['token'];
      state = AsyncValue.data(user);
      
      // ⭐ AJOUTER : Connecter WebSocket
      _ref.read(socketServiceProvider).connect(user.id, token);
      
      print('✅ AuthNotifier: Connexion réussie - ${user.name}');
    } catch (e, st) {
      print('❌ AuthNotifier: Erreur connexion - $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      print('🔐 AuthNotifier: Connexion Google en cours...');
      
      final result = await _repository.signInWithGoogle();
      
      final user = result['user'];
      final token = result['token'];
      state = AsyncValue.data(user);
      
      // ⭐ AJOUTER : Connecter WebSocket
      _ref.read(socketServiceProvider).connect(user.id, token);
      
      print('✅ AuthNotifier: Connexion Google réussie - ${user.name}');
    } catch (e, st) {
      print('❌ AuthNotifier: Erreur Google Sign-In - $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      print('🔓 AuthNotifier: Déconnexion en cours...');
      
      // ⭐ AJOUTER : Déconnecter WebSocket
      _ref.read(socketServiceProvider).disconnect();
      
      await _repository.logout();
      
      _ref.invalidate(tabsProvider);
      _ref.invalidate(friendsNotifierProvider);
      _ref.invalidate(activityProvider);
      
      state = const AsyncValue.data(null);
      
      print('✅ AuthNotifier: Déconnexion réussie');
    } catch (e, st) {
      print('❌ AuthNotifier: Erreur lors de la déconnexion - $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});