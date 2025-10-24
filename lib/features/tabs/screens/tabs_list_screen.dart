// lib/features/tabs/screens/tabs_list_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../widgets/tab_card.dart';
import '../widgets/balance_widget.dart';

class TabsListScreen extends StatefulWidget {
  const TabsListScreen({Key? key}) : super(key: key);

  @override
  State<TabsListScreen> createState() => _TabsListScreenState();
}

class _TabsListScreenState extends State<TabsListScreen> {
  String _selectedFilter = 'all';
  
  // lib/features/tabs/screens/tabs_list_screen.dart
// Remplace juste la section _mockTabs

final List<TabModel> _mockTabs = [
  TabModel(
    id: '1',
    creditorId: 'current_user',
    creditorName: 'Moi',
    debtorId: 'paul_123',
    debtorName: 'Paul',
    amount: 47.50,
    description: '🍕 Pizza vendredi soir',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    status: TabStatus.confirmed,
  ),
  TabModel(
    id: '2',
    creditorId: 'marie_456',
    creditorName: 'Marie',
    debtorId: 'current_user',
    debtorName: 'Moi',
    amount: 23.00,
    description: '🎬 Ciné samedi',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    status: TabStatus.pending,
  ),
  TabModel(
    id: '3',
    creditorId: 'current_user',
    creditorName: 'Moi',
    debtorId: 'sophie_789',
    debtorName: 'Sophie',
    amount: 15.00,
    description: '☕ Café ce matin',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    status: TabStatus.confirmed,
  ),
];

  @override
  Widget build(BuildContext context) {
    final filteredTabs = _getFilteredTabs();
    final balance = _calculateBalance();
    
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
      
      body: Column(
        children: [
          BalanceWidget(balance: balance),
          
          // Filtres
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
                  count: _countByType(true),
                  isSelected: _selectedFilter == 'they_owe',
                  onTap: () => setState(() => _selectedFilter = 'they_owe'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'À payer',
                  count: _countByType(false),
                  isSelected: _selectedFilter == 'i_owe',
                  onTap: () => setState(() => _selectedFilter = 'i_owe'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredTabs.isEmpty
                ? _EmptyState(filter: _selectedFilter)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTabs.length,
                    itemBuilder: (context, index) {
                      return TabCard(
                        tab: filteredTabs[index],
                        currentUserId: 'current_user',
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
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
            onTap: () {},
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
  
  List<TabModel> _getFilteredTabs() {
    if (_selectedFilter == 'all') {
      return _mockTabs.where((tab) => tab.status != TabStatus.settled).toList();
    } else if (_selectedFilter == 'they_owe') {
      return _mockTabs.where((tab) => 
        !tab.iOwe('current_user') && tab.status != TabStatus.settled
      ).toList();
    } else {
      return _mockTabs.where((tab) => 
        tab.iOwe('current_user') && tab.status != TabStatus.settled
      ).toList();
    }
  }
  
  int _countByType(bool theyOwe) {
    return _mockTabs.where((tab) {
      if (theyOwe) {
        return !tab.iOwe('current_user') && tab.status != TabStatus.settled;
      } else {
        return tab.iOwe('current_user') && tab.status != TabStatus.settled;
      }
    }).length;
  }
  
  double _calculateBalance() {
    double total = 0;
    for (var tab in _mockTabs) {
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
            'Commencez par créer une nouvelle tab',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}