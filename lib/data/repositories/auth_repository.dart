// lib/data/repositories/auth_repository.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final token = response['token'];
      final user = UserModel.fromJson(response['user']);

      // Sauvegarder le token
      await saveToken(token);

      return {'user': user, 'token': token};
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response['token'];
      final user = UserModel.fromJson(response['user']);

      // Sauvegarder le token
      await saveToken(token);

      return {'user': user, 'token': token};
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
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
      final user = UserModel.fromJson(response['user']);

      // Sauvegarder le token
      await saveToken(token);

      return {'user': user, 'token': token};
    } catch (e) {
      throw Exception('Erreur Google Sign-In: $e');
    }
  }

  // Récupérer l'utilisateur actuel
  Future<UserModel> getMe() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get('/auth/me');
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await deleteToken();
    await _googleSignIn.signOut();
    _apiService.removeAuthToken();
  }

  // Gestion du token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _apiService.setAuthToken(token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}