// lib/features/tabs/providers/tabs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/tab_model.dart';
import '../../../data/repositories/tab_repository.dart';
import '../../../data/services/api_service.dart';
import '../../activity/providers/activity_provider.dart'; // ← AJOUTER CET IMPORT

// Provider pour ApiService (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider pour TabRepository
final tabRepositoryProvider = Provider<TabRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TabRepository(apiService);
});

// Provider pour la liste des tabs
final tabsProvider = FutureProvider.autoDispose<List<TabModel>>((ref) async {
  final repository = ref.watch(tabRepositoryProvider);
  return repository.getTabs();
});

// Provider pour une tab spécifique
final tabByIdProvider = FutureProvider.autoDispose.family<TabModel, String>(
  (ref, id) async {
    final repository = ref.watch(tabRepositoryProvider);
    return repository.getTabById(id);
  },
);

// State notifier pour les actions
class TabsNotifier extends StateNotifier<AsyncValue<void>> {
  TabsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));
  
  final TabRepository _repository;
  final Ref _ref;
  
  Future<void> createTab(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTab(data);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(activityProvider); // ← AJOUTER
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateTab(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTab(id, data);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(activityProvider); // ← AJOUTER
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> deleteTab(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTab(id);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(activityProvider); // ← AJOUTER
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> confirmTab(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.confirmTab(id);
      _ref.invalidate(tabsProvider);
      _ref.invalidate(activityProvider); // ← AJOUTER
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
Future<void> requestRepayment(String tabId) async {
  state = const AsyncValue.loading();
  try {
    await _repository.requestRepayment(tabId);
    _ref.invalidate(tabsProvider);
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