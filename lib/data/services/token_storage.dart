// lib/data/services/token_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // ⭐ AJOUTER

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('💾 Token saved');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('🔑 Token retrieved: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    print('🗑️ Token deleted');
  }

  // ⭐ CORRIGER CETTE MÉTHODE
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user)); // ⭐ jsonEncode
    print('💾 User saved');
  }

  // ⭐ AJOUTER CETTE MÉTHODE
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erreur parse user: $e');
      return null;
    }
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}