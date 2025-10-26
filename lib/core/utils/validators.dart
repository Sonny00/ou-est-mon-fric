// lib/core/utils/validators.dart

import 'package:flutter/material.dart';

class Validators {
  // Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }

  // Mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    
    // Au moins une majuscule
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins 1 majuscule requise';
    }
    
    // Au moins une minuscule
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Au moins 1 minuscule requise';
    }
    
    // Au moins un chiffre
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Au moins 1 chiffre requis';
    }
    
    // Au moins un caractère spécial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Au moins 1 caractère spécial requis (!@#\$%...)'; // ← Échappé avec \
    }
    
    return null;
  }

  // Nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    return null;
  }

  // Téléphone (optionnel mais validé si rempli)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }

  // Force du mot de passe (pour l'indicateur visuel)
  static double getPasswordStrength(String password) {
    double strength = 0.0;
    
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;
    
    return strength;
  }

  static String getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'Faible';
    if (strength < 0.6) return 'Moyen';
    if (strength < 0.8) return 'Bon';
    return 'Excellent';
  }

  static Color getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return const Color(0xFFEF5350); // Rouge
    if (strength < 0.6) return const Color(0xFFFFA726); // Orange
    if (strength < 0.8) return const Color(0xFF66BB6A); // Vert clair
    return const Color(0xFF4CAF50); // Vert foncé
  }
}