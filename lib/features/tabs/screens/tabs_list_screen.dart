// lib/features/tabs/screens/tabs_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../widgets/tab_card.dart';
import '../widgets/balance_widget.dart';
import '../providers/tabs_provider.dart';

class TabsListScreen extends ConsumerStatefulWidget {
  const TabsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TabsListScreen> createState() => _TabsListScreenState();
}

class _TabsListScreenState extends ConsumerState<TabsListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final tabsAsync = ref.watch(tabsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('OuEstMonFric'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.user, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      
      body: tabsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
        
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.close_circle,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de connexion',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(tabsProvider),
                icon: const Icon(Iconsax.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        
        data: (tabs) {
          if (tabs.isEmpty) {
            return _buildEmptyState();
          }
          
          final filteredTabs = _getFilteredTabs(tabs);
          final balance = _calculateBalance(tabs);
          
          return Column(
            children: [
              BalanceWidget(balance: balance),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tout',
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'À recevoir',
                      count: _countByType(tabs, true),
                      isSelected: _selectedFilter == 'they_owe',
                      onTap: () => setState(() => _selectedFilter = 'they_owe'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'À payer',
                      count: _countByType(tabs, false),
                      isSelected: _selectedFilter == 'i_owe',
                      onTap: () => setState(() => _selectedFilter = 'i_owe'),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: filteredTabs.isEmpty
                    ? _EmptyState(filter: _selectedFilter)
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: () async {
                          ref.refresh(tabsProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTabs.length,
                          itemBuilder: (context, index) {
                            return TabCard(
                              tab: filteredTabs[index],
                              currentUserId: 'current_user',
                              onTap: () {
                                // TODO: Navigate to detail
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showCreateTabDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              child: const Icon(
                Iconsax.add,
                color: AppColors.background,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            child: const Icon(
              Iconsax.empty_wallet,
              size: 36,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première tab',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateTabDialog,
            icon: const Icon(Iconsax.add),
            label: const Text('Créer une tab'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCreateTabDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulaire de création à venir'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
  
  List<TabModel> _getFilteredTabs(List<TabModel> tabs) {
    if (_selectedFilter == 'all') {
      return tabs.where((tab) => tab.status != TabStatus.settled).toList();
    } else if (_selectedFilter == 'they_owe') {
      return tabs.where((tab) => 
        !tab.iOwe('current_user') && tab.status != TabStatus.settled
      ).toList();
    } else {
      return tabs.where((tab) => 
        tab.iOwe('current_user') && tab.status != TabStatus.settled
      ).toList();
    }
  }
  
  int _countByType(List<TabModel> tabs, bool theyOwe) {
    return tabs.where((tab) {
      if (theyOwe) {
        return !tab.iOwe('current_user') && tab.status != TabStatus.settled;
      } else {
        return tab.iOwe('current_user') && tab.status != TabStatus.settled;
      }
    }).length;
  }
  
  double _calculateBalance(List<TabModel> tabs) {
    double total = 0;
    for (var tab in tabs) {
      if (tab.status == TabStatus.settled) continue;
      
      if (tab.iOwe('current_user')) {
        total -= tab.amount;
      } else {
        total += tab.amount;
      }
    }
    return total;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.background.withOpacity(0.2)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  
  const _EmptyState({required this.filter});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Iconsax.empty_wallet,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMessage(filter),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getMessage(String filter) {
    switch (filter) {
      case 'they_owe':
        return 'Personne ne te doit d\'argent';
      case 'i_owe':
        return 'Tu ne dois rien à personne';
      default:
        return 'Commencez par créer une nouvelle tab';
    }
  }
}