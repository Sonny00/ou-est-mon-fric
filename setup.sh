#!/bin/bash

echo "íº€ CrÃ©ation de l'arborescence OuEstMonFric..."

# Supprimer les fichiers de test par dÃ©faut
rm -rf test/
rm lib/main.dart

# CrÃ©er la structure des dossiers
mkdir -p lib/core/{theme,constants,utils}
mkdir -p lib/features/{auth,tabs,contacts,notifications,profile}/{screens,widgets,providers}
mkdir -p lib/data/{models,repositories,services}
mkdir -p lib/shared/widgets
mkdir -p assets/{images,icons}
mkdir -p fonts

# Core
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF00D9A3);
  static const Color secondaryOrange = Color(0xFFFF6B35);
  static const Color accentYellow = Color(0xFFFFC93C);
  
  static const Color positiveGreen = Color(0xFF4CAF50);
  static const Color negativeRed = Color(0xFFE53935);
  static const Color pendingYellow = Color(0xFFFFA726);
  static const Color neutralGray = Color(0xFF9E9E9E);
  
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: secondaryOrange,
        background: backgroundColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
    );
  }
}
EOF

touch lib/core/constants/app_constants.dart
touch lib/core/utils/helpers.dart
touch lib/core/utils/validators.dart

# Features - Auth
touch lib/features/auth/screens/login_screen.dart
touch lib/features/auth/screens/verify_otp_screen.dart
touch lib/features/auth/screens/setup_profile_screen.dart
touch lib/features/auth/widgets/phone_input_widget.dart
touch lib/features/auth/providers/auth_provider.dart

# Features - Tabs
touch lib/features/tabs/screens/tabs_list_screen.dart
touch lib/features/tabs/screens/create_tab_screen.dart
touch lib/features/tabs/screens/tab_detail_screen.dart
touch lib/features/tabs/widgets/tab_card.dart
touch lib/features/tabs/widgets/balance_widget.dart
touch lib/features/tabs/widgets/reminder_messages_sheet.dart
touch lib/features/tabs/providers/tabs_provider.dart

# Features - Contacts
touch lib/features/contacts/screens/contacts_screen.dart
touch lib/features/contacts/screens/add_contact_screen.dart
touch lib/features/contacts/widgets/contact_card.dart
touch lib/features/contacts/providers/contacts_provider.dart

# Features - Notifications
touch lib/features/notifications/screens/notifications_screen.dart
touch lib/features/notifications/widgets/notification_card.dart
touch lib/features/notifications/providers/notifications_provider.dart
touch lib/features/notifications/services/fcm_service.dart

# Features - Profile
touch lib/features/profile/screens/profile_screen.dart
touch lib/features/profile/screens/edit_profile_screen.dart
touch lib/features/profile/screens/settings_screen.dart
touch lib/features/profile/screens/stats_screen.dart
touch lib/features/profile/widgets/stats_card.dart
touch lib/features/profile/providers/profile_provider.dart

# Data - Models
cat > lib/data/models/tab_model.dart << 'EOF'
enum TabStatus {
  pending,
  confirmed,
  disputed,
  settled,
}

class TabModel {
  final String id;
  final String creditorId;
  final String debtorId;
  final double amount;
  final String description;
  final DateTime createdAt;
  final TabStatus status;
  final String? proofImageUrl;
  final DateTime? settledAt;
  final String? disputeReason;
  
  TabModel({
    required this.id,
    required this.creditorId,
    required this.debtorId,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
    this.proofImageUrl,
    this.settledAt,
    this.disputeReason,
  });

  bool iOwe(String currentUserId) {
    return debtorId == currentUserId;
  }

  factory TabModel.fromJson(Map<String, dynamic> json) {
    return TabModel(
      id: json['id'],
      creditorId: json['creditorId'],
      debtorId: json['debtorId'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      status: TabStatus.values.firstWhere(
        (e) => e.toString() == 'TabStatus.${json['status']}',
      ),
      proofImageUrl: json['proofImageUrl'],
      settledAt: json['settledAt'] != null 
          ? DateTime.parse(json['settledAt']) 
          : null,
      disputeReason: json['disputeReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditorId': creditorId,
      'debtorId': debtorId,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'proofImageUrl': proofImageUrl,
      'settledAt': settledAt?.toIso8601String(),
      'disputeReason': disputeReason,
    };
  }
}
EOF

cat > lib/data/models/user_model.dart << 'EOF'
class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  String get displayName => name ?? phoneNumber;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
EOF

touch lib/data/models/notification_model.dart
touch lib/data/models/contact_model.dart
touch lib/data/repositories/tab_repository.dart
touch lib/data/repositories/user_repository.dart
touch lib/data/services/api_service.dart
touch lib/data/services/storage_service.dart
touch lib/data/services/image_service.dart

# Shared
touch lib/shared/widgets/custom_button.dart
touch lib/shared/widgets/custom_text_field.dart
touch lib/shared/widgets/loading_indicator.dart
touch lib/shared/widgets/empty_state.dart
touch lib/shared/widgets/error_widget.dart

# Main
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
EOF

cat > lib/app.dart << 'EOF'
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/tabs/screens/tabs_list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OuEstMonFric',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TabsListScreen(),
    );
  }
}
EOF

cat > lib/features/tabs/screens/tabs_list_screen.dart << 'EOF'
import 'package:flutter/material.dart';

class TabsListScreen extends StatelessWidget {
  const TabsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('í²¸ ', style: TextStyle(fontSize: 24)),
            Text('OuEstMonFric'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('í´·', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'Bienvenue sur OuEstMonFric !',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Aucune tab pour le moment',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create tab
        },
        icon: Icon(Icons.add),
        label: Text('Nouvelle tab'),
      ),
    );
  }
}
EOF

# CrÃ©er .gitkeep pour assets
touch assets/images/.gitkeep
touch assets/icons/.gitkeep
touch fonts/.gitkeep

echo "âœ… Structure crÃ©Ã©e avec succÃ¨s !"
echo ""
echo "í³‚ Fichiers crÃ©Ã©s dans lib/"
ls -R lib/
