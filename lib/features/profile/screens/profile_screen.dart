// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/user_stats_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(userStatsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: authState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Text('Erreur: $error'),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Non connecté'));
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              ref.invalidate(userStatsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header profil
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppStyles.card(),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.phoneNumber!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Modification du profil à venir'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Modifier le profil'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats dynamiques
                statsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      children: [
                        const Icon(Iconsax.danger, color: AppColors.error, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Erreur de chargement des stats',
                          style: TextStyle(color: AppColors.error),
                        ),
                        TextButton(
                          onPressed: () => ref.invalidate(userStatsProvider),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                  data: (stats) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Tabs actives',
                              value: stats.activeTabs.toString(),
                              icon: Iconsax.wallet_25,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Amis',
                              value: stats.totalFriends.toString(),
                              icon: Iconsax.people5,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'À recevoir',
                              value: '${stats.totalOwed.toStringAsFixed(0)}€',
                              icon: Iconsax.arrow_down,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'À payer',
                              value: '${stats.totalDue.toStringAsFixed(0)}€',
                              icon: Iconsax.arrow_up,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Paramètres
                _SettingsSection(
                  title: 'Général',
                  items: [
                    _SettingsItem(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Iconsax.shield_tick,
                      title: 'Confidentialité',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Iconsax.bank,
                      title: 'Comptes bancaires',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _SettingsSection(
                  title: 'Support',
                  items: [
                    _SettingsItem(
                      icon: Iconsax.message_question,
                      title: 'Aide',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsItem(
                      icon: Iconsax.document_text,
                      title: 'Conditions d\'utilisation',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _SettingsSection(
                  title: 'Compte',
                  items: [
                    _SettingsItem(
                      icon: Iconsax.logout,
                      title: 'Déconnexion',
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                const Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.card(),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  
  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: AppStyles.card(),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Container(
                        height: 0.5,
                        color: AppColors.divider,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}