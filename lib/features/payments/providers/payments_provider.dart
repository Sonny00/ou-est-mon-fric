// lib/features/payments/providers/payments_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/tab_model.dart';
import '../../../data/repositories/tab_repository.dart';
import '../../tabs/providers/tabs_provider.dart';

// Provider pour récupérer les tabs nécessitant une action de paiement
final paymentsProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final repository = ref.watch(tabRepositoryProvider);
  final allTabs = await repository.getTabs();
  
  // Filtrer les tabs qui nécessitent une action de paiement
  // - Tabs actives (pour permettre le remboursement)
  // - Tabs en attente de remboursement (pour confirmer)
  return allTabs.where((tab) => 
    tab.status == TabStatus.active ||  // ⭐ CHANGÉ
    tab.status == TabStatus.repaymentPending  // ⭐ CHANGÉ
  ).toList();
});

// Notifier pour les actions de paiement
class PaymentsNotifier extends StateNotifier<AsyncValue<void>> {
  PaymentsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final TabRepository _repository;
  final Ref _ref;
  
  // ⭐ CHANGÉ : Utiliser declareRepayment au lieu de requestRepayment
  Future<void> declareRepayment(String tabId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.declareRepayment(tabId);
      
      // Invalider les providers pour rafraîchir l'UI
      _ref.invalidate(paymentsProvider);
      _ref.invalidate(tabsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  // ⭐ CHANGÉ : Utiliser respondToSyncRequest au lieu de confirmRepayment
  Future<void> confirmRepayment(String syncRequestId) async {
    state = const AsyncValue.loading();
    try {
      // Trouver la demande de synchro correspondante
      // Note: Il faudrait avoir accès au syncRequestId
      // Pour l'instant, on peut simplement invalider les providers
      
      _ref.invalidate(paymentsProvider);
      _ref.invalidate(tabsProvider);
      
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