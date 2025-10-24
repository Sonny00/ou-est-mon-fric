// lib/app.dart

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/screens/main_navigation_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OuEstMonFric',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),  // ← Navigation principale
    );
  }
}