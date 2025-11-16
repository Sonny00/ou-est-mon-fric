// lib/features/tabs/screens/tabs_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tab_model.dart';
import '../widgets/tab_card.dart';
import '../widgets/balance_widget.dart';
import '../providers/tabs_provider.dart';
import 'create_tab_screen.dart';
import 'edit_tab_screen.dart'; 
import '../../auth/providers/auth_provider.dart'; 
import '../../payments/screens/payments_screen.dart';


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
    final currentUser = ref.watch(authStateProvider).value; 
    final currentUserId = currentUser?.id ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('OuEstMonFric'),
        actions: [
           IconButton(
            icon: const Icon(Iconsax.wallet_money, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentsScreen(),
                ),
              );
            },
          ),
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
                mainAxisAlignment: MainAxisAlignment.center, 
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
                              currentUserId: currentUserId,
                              onTap: () => _showTabDetails(filteredTabs[index]), // ← MODIFIER cette ligne
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTabScreen(),
      ),
    );
  }

  void _showTabDetails(TabModel tab) {
  final currentUser = ref.read(authStateProvider).value;  // ✅ AJOUTER
  final currentUserId = currentUser?.id ?? '';  
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: tab.iOwe(currentUserId) 
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tab.iOwe(currentUserId) ? Iconsax.arrow_up : Iconsax.arrow_down,
                        color: tab.iOwe(currentUserId) ? AppColors.error : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tab.iOwe(currentUserId) 
                                ? 'Tu dois à ${tab.creditorName}'
                                : '${tab.debtorName} te doit',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tab.amount.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: tab.iOwe(currentUserId) ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tab.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Deadline si présente
                if (tab.hasDeadline) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tab.isOverdue 
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tab.isOverdue ? AppColors.error : AppColors.accent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.isOverdue ? Iconsax.danger : Iconsax.clock,
                          color: tab.isOverdue ? AppColors.error : AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tab.isOverdue ? 'En retard !' : 'Date limite',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: tab.isOverdue ? AppColors.error : AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tab.deadlineStatus,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
            // Actions
Row(
  children: [
    // ⭐ Bouton Confirmer (seulement si pending et je suis le débiteur)
    if (tab.status == TabStatus.pending && tab.debtorId == currentUserId)
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context); // Fermer le modal
            try {
              await ref.read(tabsNotifierProvider.notifier).confirmTab(tab.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tab confirmée !'),
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
          label: const Text('Confirmer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    
    // Espacement si le bouton confirmer est visible
    if (tab.status == TabStatus.pending && tab.debtorId == currentUserId)
      const SizedBox(width: 12),
    
    // Bouton Modifier
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () async {
          Navigator.pop(context);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTabScreen(tab: tab),
            ),
          );
          if (result == true) {
            ref.refresh(tabsProvider);
          }
        },
        icon: const Icon(Iconsax.edit, size: 18),
        label: const Text('Modifier'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    
    const SizedBox(width: 12),
    
    // Bouton Supprimer
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showDeleteConfirmation(tab);
        },
        icon: const Icon(Iconsax.trash, size: 18),
        label: const Text('Supprimer'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  ],
),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TabModel tab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Supprimer cette tab ?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Cette action est irréversible.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(tabsNotifierProvider.notifier).deleteTab(tab.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tab supprimée'),
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
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  // =========================================
  
 List<TabModel> _getFilteredTabs(List<TabModel> tabs) {
  final currentUser = ref.read(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';
  
  if (_selectedFilter == 'all') {
    return tabs.where((tab) => tab.status != TabStatus.settled).toList();
  } else if (_selectedFilter == 'they_owe') {
    return tabs.where((tab) => 
      !tab.iOwe(currentUserId) && tab.status != TabStatus.settled
    ).toList();
  } else {
    return tabs.where((tab) => 
      tab.iOwe(currentUserId) && tab.status != TabStatus.settled
    ).toList();
  }
}
  
  int _countByType(List<TabModel> tabs, bool theyOwe) {
  final currentUser = ref.read(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';
  
  return tabs.where((tab) {
    if (theyOwe) {
      return !tab.iOwe(currentUserId) && tab.status != TabStatus.settled;
    } else {
      return tab.iOwe(currentUserId) && tab.status != TabStatus.settled;
    }
  }).length;
}
  
double _calculateBalance(List<TabModel> tabs) {
  final currentUser = ref.read(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';
  
  double total = 0;
  print('🔍 === CALCUL DE LA BALANCE ===');
  
  for (var tab in tabs) {
    if (tab.status == TabStatus.settled) continue;
    
    print('📋 Tab: ${tab.description}');
    print('   Creditor: ${tab.creditorName} (${tab.creditorId})');
    print('   Debtor: ${tab.debtorName} (${tab.debtorId})');
    print('   Amount: ${tab.amount}€');
    print('   iOwe result: ${tab.iOwe(currentUserId)}');  // ✅ CORRIGÉ
    
    if (tab.iOwe(currentUserId)) {  // ✅ CORRIGÉ
      print('   ➖ JE DOIS: -${tab.amount}€');
      total -= tab.amount;
    } else {
      print('   ➕ ON ME DOIT: +${tab.amount}€');
      total += tab.amount;
    }
    print('   Balance courante: $total€');
  }
  
  print('💰 BALANCE FINALE: $total€');
  print('============================');
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