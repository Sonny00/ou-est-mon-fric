// lib/features/tabs/providers/tabs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/tab_model.dart';
import '../../../data/models/tab_sync_request_model.dart';
import '../../../data/repositories/tab_repository.dart';
import '../../../data/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final tabRepositoryProvider = Provider<TabRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TabRepository(apiService);
});

final tabsProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final repository = ref.watch(tabRepositoryProvider);
  return repository.getTabs();
});

final tabByIdProvider = FutureProvider.autoDispose.family<TabModel, String>(
  (ref, id) async {
    final repository = ref.watch(tabRepositoryProvider);
    return repository.getTabById(id);
  },
);

// ⭐ NOUVEAU : Demandes de synchronisation en attente
final pendingSyncRequestsProvider = FutureProvider.autoDispose<List<TabSyncRequest>>((ref) async {
  final repository = ref.watch(tabRepositoryProvider);
  return repository.getPendingSyncRequests();
});

class TabsNotifier extends StateNotifier<AsyncValue<void>> {
  TabsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final TabRepository _repository;
  final Ref _ref;
  
  Future<void> createTab(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTab(data);
      _ref.invalidate(tabsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> updateTab(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTab(id, data);
      _ref.invalidate(tabsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> deleteTab(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTab(id);
      _ref.invalidate(tabsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ⭐ NOUVEAU : Déclarer un remboursement
  Future<void> declareRepayment(String tabId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.declareRepayment(tabId);
      
      _ref.invalidate(tabsProvider);
      
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _ref.read(tabsProvider.future);
      } catch (_) {}
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ⭐ NOUVEAU : Répondre à une demande de synchro
  Future<void> respondToSyncRequest(
    String syncRequestId,
    String action, {
    String? rejectionReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.respondToSyncRequest(
        syncRequestId,
        action,
        rejectionReason: rejectionReason,
      );
      
      _ref.invalidate(tabsProvider);
      _ref.invalidate(pendingSyncRequestsProvider);
      
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _ref.read(tabsProvider.future);
      } catch (_) {}
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final tabsNotifierProvider = StateNotifierProvider<TabsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(tabRepositoryProvider);
  return TabsNotifier(repository, ref);
});