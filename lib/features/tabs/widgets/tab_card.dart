// lib/features/tabs/widgets/tab_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../providers/tabs_provider.dart';

class TabCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
            // ========== HEADER (existant) ==========
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isIOwing ? AppColors.error : AppColors.success,
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
            
            // ========== BOUTONS D'ACTION RAPIDE ⭐ NOUVEAU ==========
            if (_shouldShowQuickActions())
              Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    height: 0.5,
                    color: AppColors.divider,
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, ref),
                ],
              ),
            // =====================================================
          ],
        ),
      ),
    );
  }
  
  // ========== LOGIQUE DES ACTIONS RAPIDES ==========
  bool _shouldShowQuickActions() {
    // Afficher les boutons si :
    // 1. Je dois payer ET la tab est confirmée
    // 2. On m'a payé ET je dois confirmer
    return (tab.status == TabStatus.confirmed && tab.iOwe(currentUserId)) ||
           (tab.status == TabStatus.repaymentRequested && !tab.iOwe(currentUserId));
  }
  
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    if (tab.status == TabStatus.confirmed && tab.iOwe(currentUserId)) {
      // Je dois payer
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _quickRequestRepayment(context, ref),
          icon: const Icon(Iconsax.wallet, size: 18),
          label: const Text('J\'ai payé'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    } else if (tab.status == TabStatus.repaymentRequested && !tab.iOwe(currentUserId)) {
      // On m'a payé, je dois confirmer
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _quickConfirmPayment(context, ref),
          icon: const Icon(Iconsax.tick_circle, size: 18),
          label: const Text('Confirmer la réception'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  // ========== ACTIONS ==========
  Future<void> _quickRequestRepayment(BuildContext context, WidgetRef ref) async {
    // Confirmation avant d'envoyer
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirmer le paiement',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous confirmez avoir payé ${tab.amount.toStringAsFixed(2)}€ à ${tab.creditorName} ?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tab.creditorName} devra confirmer la réception.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(tabsNotifierProvider.notifier).requestRepayment(tab.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demande envoyée à ${tab.creditorName} !'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _quickConfirmPayment(BuildContext context, WidgetRef ref) async {
    // Confirmation avant de valider
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirmer la réception',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous confirmez avoir bien reçu ${tab.amount.toStringAsFixed(2)}€ de ${tab.debtorName} ?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.tick_circle, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La tab sera marquée comme réglée.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(tabsNotifierProvider.notifier).confirmRepayment(tab.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement confirmé ! 🎉'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  // =================================================
  
  // ... reste du code inchangé (getters, etc.)
  
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

// Widgets existants inchangés
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
    case TabStatus.settled: 
      return AppColors.accentDark;
    case TabStatus.disputed: // ⭐ AJOUTER
      return AppColors.error;
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
 // Dans _StatusBadge
Map<String, dynamic> _getConfig() {
  switch (status) {
    case TabStatus.pending:
      return {
        'label': 'En attente', 
        'bgColor': AppColors.accentDark, 
        'textColor': AppColors.textSecondary
      };
    case TabStatus.confirmed:
      return {
        'label': 'Confirmé', 
        'bgColor': AppColors.accent, 
        'textColor': AppColors.background
      };
    case TabStatus.repaymentRequested:
      return {
        'label': 'À confirmer', 
        'bgColor': AppColors.warning.withOpacity(0.2), 
        'textColor': AppColors.warning
      };
    case TabStatus.settled:
      return {
        'label': 'Réglé', 
        'bgColor': AppColors.surface, 
        'textColor': AppColors.textTertiary
      };
    case TabStatus.disputed: // 
      return {
        'label': 'Contesté', 
        'bgColor': AppColors.error.withOpacity(0.1), 
        'textColor': AppColors.error
      };
  }
}
}