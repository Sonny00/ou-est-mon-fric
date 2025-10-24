// lib/features/tabs/widgets/tab_card.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';

class TabCard extends StatelessWidget {
  final TabModel tab;
  final String currentUserId;
  final VoidCallback onTap;
  
  const TabCard({
    Key? key,
    required this.tab,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIOwing = tab.iOwe(currentUserId);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: AppStyles.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getOtherUserName(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isIOwing ? 'Tu dois' : 'Te doit',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Montant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIOwing ? "−" : "+"}${tab.amount.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusIndicator(status: tab.status),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 0.5,
              color: AppColors.divider,
            ),
            
            const SizedBox(height: 14),
            
            // Description
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getEmoji(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tab.description.replaceAll(RegExp(r'[🍕🎬☕💰🎂]'), '').trim(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                _StatusBadge(status: tab.status),
                const Spacer(),
                Text(
                  _getTimeAgo(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getInitials() {
    final name = tab.iOwe(currentUserId) ? tab.creditorName : tab.debtorName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
  
  String _getOtherUserName() {
    return tab.iOwe(currentUserId) ? tab.creditorName : tab.debtorName;
  }
  
  String _getEmoji() {
    if (tab.description.contains('🍕')) return '🍕';
    if (tab.description.contains('🎬')) return '🎬';
    if (tab.description.contains('☕')) return '☕';
    if (tab.description.contains('🎂')) return '🎂';
    return '💰';
  }
  
  String _getTimeAgo() {
    final diff = DateTime.now().difference(tab.createdAt);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inMinutes}min';
  }
}

class _StatusIndicator extends StatelessWidget {
  final TabStatus status;
  
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
      ),
    );
  }
  
  Color _getColor() {
    switch (status) {
      case TabStatus.pending:
        return AppColors.textTertiary;
      case TabStatus.confirmed:
        return AppColors.accent;
      case TabStatus.repaymentRequested:
        return AppColors.warning;
      case TabStatus.disputed:
        return AppColors.textSecondary;
      case TabStatus.settled:
        return AppColors.accentDark;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TabStatus status;
  
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: config['textColor'] as Color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  Map<String, dynamic> _getConfig() {
    switch (status) {
      case TabStatus.pending:
        return {
          'label': 'En attente',
          'bgColor': AppColors.accentDark,
          'textColor': AppColors.textSecondary,
        };
      case TabStatus.confirmed:
        return {
          'label': 'Confirmé',
          'bgColor': AppColors.accent,
          'textColor': AppColors.background,
        };
      case TabStatus.repaymentRequested:
        return {
          'label': 'À confirmer',
          'bgColor': AppColors.warning.withOpacity(0.2),
          'textColor': AppColors.warning,
        };
      case TabStatus.disputed:
        return {
          'label': 'Contesté',
          'bgColor': AppColors.surfaceLight,
          'textColor': AppColors.textPrimary,
        };
      case TabStatus.settled:
        return {
          'label': 'Réglé',
          'bgColor': AppColors.surface,
          'textColor': AppColors.textTertiary,
        };
    }
  }
}