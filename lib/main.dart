import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← Déjà présent
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/navigation/screens/main_navigation_screen.dart';

void main() async {
  // ← AJOUTER CES 2 LIGNES
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OuEstMonFric',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('fr', 'FR'),
      home: const AuthWrapper(),
    );
  }
}

/// ✅ Widget qui vérifie l'état d'authentification au démarrage
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // ✅ Utilisateur connecté -> MainNavigationScreen
      data: (user) {
        if (user != null) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
      
      // ⏳ Chargement (vérification du token) -> Splash screen
      loading: () {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.wallet,
                    size: 48,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        );
      },
      
      // ❌ Erreur -> LoginScreen
      error: (error, stack) {
        return const LoginScreen();
      },
    );
  }
}