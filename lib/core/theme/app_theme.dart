// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Soft gray palette (plus clair que noir)
  static const background = Color(0xFF1A1A1A);        // Gris anthracite
  static const surface = Color(0xFF252525);           // Cards
  static const surfaceLight = Color(0xFF2F2F2F);      // Hover
  
  // Texte
  static const textPrimary = Color(0xFFEEEEEE);       // Blanc très doux
  static const textSecondary = Color(0xFFB0B0B0);     // Gris moyen
  static const textTertiary = Color(0xFF707070);      // Gris foncé
  
  // Borders
  static const border = Color(0xFF3A3A3A);
  static const divider = Color(0xFF2F2F2F);
  
  // Accents
  static const accent = Color(0xFFE8E8E8);            
  static const accentDark = Color(0xFF4A4A4A);
  
  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: false,
      fontFamily: 'Inter', // Font moderne et neutre
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

class AppStyles {
  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.border,
        width: 1,
      ),
    );
  }
  
  static BoxDecoration elevatedCard() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.border,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  static BoxDecoration primaryButton({bool isPressed = false}) {
    return BoxDecoration(
      color: isPressed ? AppColors.accent.withOpacity(0.9) : AppColors.accent,
      borderRadius: BorderRadius.circular(12),
    );
  }
}