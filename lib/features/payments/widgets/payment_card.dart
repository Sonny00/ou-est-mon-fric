// lib/features/payments/widgets/payment_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentCard extends ConsumerWidget {
  final TabModel tab;
  final VoidCallback? onTap;
  final Widget? actions;
  
  const PaymentCard({
    Key? key,
    required this.tab,
    this.onTap,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final currentUserId = currentUser?.id ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppStyles.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(currentUserId),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tab.iOwe(currentUserId) 
                                ? tab.creditorName 
                                : tab.debtorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tab.amount.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (tab.repaymentRequestedAt != null)
                          Text(
                            _getTimeAgo(tab.repaymentRequestedAt!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getInitials(String currentUserId) {
    final name = tab.iOwe(currentUserId) 
        ? tab.creditorName 
        : tab.debtorName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
  
  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inMinutes}min';
  }
}
