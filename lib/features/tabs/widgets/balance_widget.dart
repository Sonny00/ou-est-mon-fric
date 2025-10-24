// lib/features/tabs/widgets/balance_widget.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BalanceWidget extends StatelessWidget {
  final double balance;
  
  const BalanceWidget({
    Key? key,
    required this.balance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.elevatedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,  // ← CENTRÉ
        children: [
          // Label centré
          Text(
            'Balance totale',
            textAlign: TextAlign.center,  // ← CENTRÉ
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: -0.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Montant centré
          Row(
            mainAxisAlignment: MainAxisAlignment.center,  // ← CENTRÉ
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${balance >= 0 ? "+" : "−"}${balance.abs().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '€',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
           
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive ? AppColors.accent : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isPositive ? 'Créditeur' : 'Débiteur',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPositive ? AppColors.background : AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}