// lib/features/payments/screens/payments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/payments_provider.dart';
import '../widgets/payment_card.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final currentUserId = currentUser?.id ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiements'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'À payer'),
            Tab(text: 'À confirmer'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PaymentsToMakeTab(currentUserId: currentUserId),
          _PaymentsToConfirmTab(currentUserId: currentUserId),
          _PaymentHistoryTab(currentUserId: currentUserId),
        ],
      ),
    );
  }
}

// Onglet 1 : À payer (je dois payer)
class _PaymentsToMakeTab extends ConsumerWidget {
  final String currentUserId;
  
  const _PaymentsToMakeTab({required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(pendingPaymentsProvider);
    
    return paymentsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(pendingPaymentsProvider)),
      data: (payments) {
        if (payments.isEmpty) {
          return _EmptyState(
            icon: Iconsax.wallet_check,
            title: 'Aucun paiement en attente',
            subtitle: 'Vous n\'avez aucun paiement à effectuer',
          );
        }
        
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async => ref.invalidate(pendingPaymentsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return PaymentCard(
                tab: payment,
                actions: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showPaymentProof(context, ref, payment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                        ),
                        child: const Text('J\'ai payé'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  void _showPaymentProof(BuildContext context, WidgetRef ref, tab) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirmer le paiement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'En confirmant, vous indiquez que vous avez payé cette dette.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(paymentsNotifierProvider.notifier)
                            .requestRepayment(tab.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paiement signalé !'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Onglet 2 : À confirmer (on m'a payé)
class _PaymentsToConfirmTab extends ConsumerWidget {
  final String currentUserId;
  
  const _PaymentsToConfirmTab({required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsToConfirmProvider);
    
    return paymentsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(paymentsToConfirmProvider)),
      data: (payments) {
        if (payments.isEmpty) {
          return _EmptyState(
            icon: Iconsax.tick_circle,
            title: 'Aucun paiement à confirmer',
            subtitle: 'Les paiements reçus apparaîtront ici',
          );
        }
        
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async => ref.invalidate(paymentsToConfirmProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return PaymentCard(
                tab: payment,
                actions: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ref.read(paymentsNotifierProvider.notifier)
                                .confirmRepayment(payment.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paiement confirmé !'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Iconsax.tick_circle, size: 18),
                        label: const Text('Confirmer la réception'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Onglet 3 : Historique
class _PaymentHistoryTab extends ConsumerWidget {
  final String currentUserId;
  
  const _PaymentHistoryTab({required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(paymentHistoryProvider);
    
    return historyAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(paymentHistoryProvider)),
      data: (history) {
        if (history.isEmpty) {
          return _EmptyState(
            icon: Iconsax.receipt_2,
            title: 'Aucun historique',
            subtitle: 'Les paiements confirmés apparaîtront ici',
          );
        }
        
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async => ref.invalidate(paymentHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final payment = history[index];
              return PaymentCard(tab: payment);
            },
          ),
        );
      },
    );
  }
}

// Widget Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Error State
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.danger, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}