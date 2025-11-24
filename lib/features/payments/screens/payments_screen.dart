// lib/features/payments/screens/payments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../../tabs/providers/tabs_provider.dart';

// ⭐ NOUVEAUX PROVIDERS pour remplacer les anciens
final pendingPaymentsProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final allTabs = ref.watch(tabsProvider).value ?? [];
  return allTabs.where((tab) => 
    tab.status == TabStatus.active
  ).toList();
});

final paymentsToConfirmProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final allTabs = ref.watch(tabsProvider).value ?? [];
  return allTabs.where((tab) => 
    tab.status == TabStatus.repaymentPending
  ).toList();
});

final paymentHistoryProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final allTabs = ref.watch(tabsProvider).value ?? [];
  return allTabs.where((tab) => 
    tab.status == TabStatus.settled
  ).toList();
});

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Paiements'),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'À payer'),
              Tab(text: 'À confirmer'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PaymentsToMakeTab(),
            _PaymentsToConfirmTab(),
            _PaymentHistoryTab(),
          ],
        ),
      ),
    );
  }
}

// ========== TAB 1 : Paiements à faire ==========
class _PaymentsToMakeTab extends ConsumerWidget {
  const _PaymentsToMakeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(pendingPaymentsProvider);

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(pendingPaymentsProvider)),
      data: (payments) {
        if (payments.isEmpty) {
          return const _EmptyState(
            icon: Iconsax.tick_circle,
            title: 'Rien à payer',
            subtitle: 'Vous êtes à jour !',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingPaymentsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final tab = payments[index];
              return _PaymentCard(
                tab: tab,
                onPay: () => _handlePayment(context, ref, tab),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handlePayment(BuildContext context, WidgetRef ref, TabModel tab) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer le paiement', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Confirmer avoir payé ${tab.amount.toStringAsFixed(2)}€ à ${tab.creditorName} ?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // ⭐ CHANGÉ : utiliser declareRepayment
        await ref.read(tabsNotifierProvider.notifier).declareRepayment(tab.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande de paiement envoyée'),
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
    }
  }
}

// ========== TAB 2 : Paiements à confirmer ==========
class _PaymentsToConfirmTab extends ConsumerWidget {
  const _PaymentsToConfirmTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsToConfirmProvider);

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(paymentsToConfirmProvider)),
      data: (payments) {
        if (payments.isEmpty) {
          return const _EmptyState(
            icon: Iconsax.clock,
            title: 'Rien à confirmer',
            subtitle: 'Aucun paiement en attente',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(paymentsToConfirmProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final tab = payments[index];
              return _ConfirmPaymentCard(tab: tab);
            },
          ),
        );
      },
    );
  }
}

// ========== TAB 3 : Historique ==========
class _PaymentHistoryTab extends ConsumerWidget {
  const _PaymentHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(paymentHistoryProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(onRetry: () => ref.invalidate(paymentHistoryProvider)),
      data: (history) {
        if (history.isEmpty) {
          return const _EmptyState(
            icon: Iconsax.document,
            title: 'Aucun historique',
            subtitle: 'Vos paiements réglés apparaîtront ici',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(paymentHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final tab = history[index];
              return _HistoryCard(tab: tab);
            },
          ),
        );
      },
    );
  }
}

// ========== WIDGETS ==========

class _PaymentCard extends StatelessWidget {
  final TabModel tab;
  final VoidCallback onPay;

  const _PaymentCard({required this.tab, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'À payer à ${tab.creditorName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${tab.amount.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPay,
              icon: const Icon(Iconsax.money_send),
              label: const Text('J\'ai payé'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmPaymentCard extends StatelessWidget {
  final TabModel tab;

  const _ConfirmPaymentCard({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tab.debtorName} a payé',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${tab.amount.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Iconsax.clock, size: 16, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rendez-vous dans "Notifications" pour confirmer',
                    style: TextStyle(
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
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TabModel tab;

  const _HistoryCard({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tab.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Réglé',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.tick_circle, color: AppColors.success),
        ],
      ),
    );
  }
}

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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.close_circle, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }
}