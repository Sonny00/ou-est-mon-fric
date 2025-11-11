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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label centré
          const Text(
            'Balance totale',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: -0.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Montant centré avec couleur dynamique
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${balance >= 0 ? "+" : "−"}${balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.error, // ← Couleur dynamique
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '€',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error, // ← Couleur dynamique
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Badge avec meilleure distinction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive 
                  ? AppColors.success.withOpacity(0.15)  // ← Vert clair pour créditeur
                  : AppColors.error.withOpacity(0.15),   // ← Rouge clair pour débiteur
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPositive ? AppColors.success : AppColors.error, // ← Bordure colorée
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  isPositive ? 'Créditeur' : 'Débiteur',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.success : AppColors.error, // ← Texte coloré
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}