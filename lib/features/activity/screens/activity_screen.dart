// lib/features/activity/screens/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activité'),
      ),
      body: activitiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
        
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.close_circle,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(activityProvider),
                icon: const Icon(Iconsax.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
        
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.activity,
                      size: 36,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aucune activité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les activités apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              ref.refresh(activityProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return _ActivityItem(activity: activities[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityModel activity;
  
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final config = _getActivityConfig(activity.type);
    
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
              color: config['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              config['icon'],
              size: 20,
              color: config['color'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.getTimeAgo(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _getActivityConfig(ActivityType type) {
    switch (type) {
      case ActivityType.tabCreated:
        return {
          'icon': Iconsax.add_circle5,
          'color': AppColors.accent,
        };
      case ActivityType.tabConfirmed:
        return {
          'icon': Iconsax.tick_circle5,
          'color': AppColors.success,
        };
      case ActivityType.repaymentRequested:
        return {
          'icon': Iconsax.wallet_35,
          'color': AppColors.warning,
        };
      case ActivityType.repaymentConfirmed:
        return {
          'icon': Iconsax.tick_circle5,
          'color': AppColors.success,
        };
      case ActivityType.friendAdded:
        return {
          'icon': Iconsax.user_add5,
          'color': AppColors.textSecondary,
        };
      case ActivityType.tabDeleted:
        return {
          'icon': Iconsax.trash5,
          'color': AppColors.error,
        };
    }
  }
}