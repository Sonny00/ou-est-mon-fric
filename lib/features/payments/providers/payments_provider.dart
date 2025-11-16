// lib/features/payments/providers/payments_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/tab_model.dart';
import '../../../data/repositories/tab_repository.dart';
import '../../tabs/providers/tabs_provider.dart';
import '../../auth/providers/auth_provider.dart';

// Provider pour les tabs où je dois demander un remboursement
// (Je suis débiteur, statut = confirmed)
final pendingPaymentsProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final tabs = await ref.watch(tabsProvider.future);
  final currentUser = ref.watch(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';
  
  return tabs.where((tab) => 
    tab.debtorId == currentUserId && 
    tab.status == TabStatus.confirmed
  ).toList();
});

// Provider pour les remboursements à confirmer
// (Je suis créditeur, quelqu'un a demandé à me rembourser)
final paymentsToConfirmProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final tabs = await ref.watch(tabsProvider.future);
  final currentUser = ref.watch(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';
  
  return tabs.where((tab) => 
    tab.creditorId == currentUserId && 
    tab.status == TabStatus.repaymentRequested
  ).toList();
});

// Provider pour l'historique (paiements réglés)
final paymentHistoryProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final tabs = await ref.watch(tabsProvider.future);
  return tabs.where((tab) => tab.status == TabStatus.settled).toList();
});

// Notifier pour les actions sur les paiements
class PaymentsNotifier extends StateNotifier<AsyncValue<void>> {
  PaymentsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final TabRepository _repository;
  final Ref _ref;
  
  Future<void> requestRepayment(String tabId, {String? proofImageUrl}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.requestRepayment(tabId, proofImageUrl: proofImageUrl);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(pendingPaymentsProvider);
      _ref.invalidate(paymentsToConfirmProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> confirmRepayment(String tabId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.confirmRepayment(tabId);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(paymentsToConfirmProvider);
      _ref.invalidate(paymentHistoryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final paymentsNotifierProvider = StateNotifierProvider<PaymentsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(tabRepositoryProvider);
  return PaymentsNotifier(repository, ref);
});
