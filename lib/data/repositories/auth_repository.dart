// lib/data/repositories/auth_repository.dart

import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../services/token_storage.dart'; // ⭐ UTILISER UNIQUEMENT CELUI-CI

class AuthRepository {
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthRepository(this._apiService);

  // Inscription
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      print('📡 AuthRepository: Register...');
      
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      print('📦 Register response: $response');

      final token = response['token'];
      final userData = response['user'];
      final user = UserModel.fromJson(userData);

      // ⭐ SAUVEGARDER TOKEN ET USER AVEC TokenStorage
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(userData); // ⭐ AJOUTER CETTE LIGNE
      
      print('✅ Token et user sauvegardés');

      return {'user': user, 'token': token};
    } catch (e) {
      print('❌ AuthRepository register error: $e');
      rethrow;
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📡 AuthRepository: Login...');
      
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('📦 Login response: $response');

      final token = response['token'];
      final userData = response['user'];
      final user = UserModel.fromJson(userData);

      // ⭐ SAUVEGARDER TOKEN ET USER AVEC TokenStorage
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(userData); // ⭐ AJOUTER CETTE LIGNE
      
      print('✅ Token et user sauvegardés');

      return {'user': user, 'token': token};
    } catch (e) {
      print('❌ AuthRepository login error: $e');
      rethrow;
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('📡 AuthRepository: Google Sign-In...');
      
      // Connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Envoyer au backend
      final response = await _apiService.post(
        '/auth/google',
        data: {
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
        },
      );

      final token = response['token'];
      final userData = response['user'];
      final user = UserModel.fromJson(userData);

      // ⭐ SAUVEGARDER TOKEN ET USER AVEC TokenStorage
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(userData); // ⭐ AJOUTER CETTE LIGNE
      
      print('✅ Token et user sauvegardés (Google)');

      return {'user': user, 'token': token};
    } catch (e) {
      print('❌ AuthRepository Google error: $e');
      rethrow;
    }
  }

  // Récupérer l'utilisateur actuel
  Future<UserModel> getMe() async {
    try {
      print('📡 AuthRepository: Get me...');
      
      final response = await _apiService.get('/auth/me');
      
      print('📦 Get me response: $response');
      
      if (response['success'] == true) {
        final userData = response['data'];
        final user = UserModel.fromJson(userData);
        
        // ⭐ BONUS : Re-sauvegarder l'user à jour
        await TokenStorage.saveUser(userData);
        print('✅ User info mise à jour');
        
        return user;
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      print('❌ AuthRepository getMe error: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      print('🔓 AuthRepository: Déconnexion...');
      
      // 1. Supprimer le token avec TokenStorage
      await TokenStorage.deleteToken();
      print('✅ Token supprimé');
      
      // 2. Tenter de déconnecter Google (si connecté)
      try {
        final isSignedIn = await _googleSignIn.isSignedIn();
        if (isSignedIn) {
          print('🔓 Déconnexion de Google...');
          await _googleSignIn.signOut();
          print('✅ Déconnexion Google réussie');
        }
      } catch (googleError) {
        print('⚠️ Impossible de déconnecter Google (ignoré): $googleError');
      }
      
      print('✅ AuthRepository: Déconnexion complète');
    } catch (e) {
      print('❌ AuthRepository logout error: $e');
      // Forcer la suppression même en cas d'erreur
      try {
        await TokenStorage.deleteToken();
      } catch (_) {}
      rethrow;
    }
  }

  // ⭐ SUPPRIMER CES MÉTHODES (on utilise TokenStorage maintenant)
  // Future<void> saveToken(String token) async { ... }
  // Future<String?> getToken() async { ... }
  // Future<void> deleteToken() async { ... }

  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }
}