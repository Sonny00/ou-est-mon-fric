// lib/features/activity/screens/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activité'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActivityItem(
            icon: Iconsax.tick_circle5,
            iconColor: AppColors.success,
            title: 'Remboursement confirmé',
            subtitle: 'Paul t\'a remboursé 47,50€',
            time: 'Il y a 2h',
          ),
          _ActivityItem(
            icon: Iconsax.add_circle5,
            iconColor: AppColors.accent,
            title: 'Nouvelle tab créée',
            subtitle: 'Marie te doit 23,00€',
            time: 'Il y a 1j',
          ),
          _ActivityItem(
            icon: Iconsax.user_add5,
            iconColor: AppColors.textSecondary,
            title: 'Nouvel ami ajouté',
            subtitle: 'Sophie a été ajoutée à vos amis',
            time: 'Il y a 3j',
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.card(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}