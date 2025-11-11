// lib/features/friends/screens/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/friend_model.dart';
import '../providers/friends_provider.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../tabs/screens/create_tab_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher un ami...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Mes Amis'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Iconsax.close_square : Iconsax.search_normal),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _searchFocusNode.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: friendsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.close_circle, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erreur', style: Theme.of(context).textTheme.displayMedium),
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
                onPressed: () => ref.read(friendsNotifierProvider.notifier).loadFriends(),
                icon: const Icon(Iconsax.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
        data: (friends) {
          if (friends.isEmpty) {
            return const _EmptyState();
          }

          final filteredFriends = _searchQuery.isEmpty
              ? friends
              : friends.where((friend) {
                  final query = _searchQuery.toLowerCase();
                  return friend.name.toLowerCase().contains(query) ||
                         (friend.phoneNumber?.contains(query) ?? false) ||
                         (friend.email?.toLowerCase().contains(query) ?? false);
                }).toList();

          if (filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.search_status, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun résultat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun ami trouvé pour "$_searchQuery"',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      const Icon(Iconsax.search_normal_1, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${filteredFriends.length} résultat${filteredFriends.length > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () async {
                    await ref.read(friendsNotifierProvider.notifier).loadFriends();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      return _FriendCard(
                        friend: filteredFriends[index],
                        searchQuery: _searchQuery,
                        // ✅ CORRECTION ICI - Crée une closure sans paramètres
                        onTap: () {
                          _showFriendDetails(context, filteredFriends[index], ref);
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
      floatingActionButton: _isSearching
          ? null
          : Container(
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
                  onTap: () => _showAddFriendDialog(context, ref),
                  borderRadius: BorderRadius.circular(16),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Iconsax.user_add, color: AppColors.background, size: 24),
                  ),
                ),
              ),
            ),
    );
  }
  
  
  
  void _showFriendDetails(BuildContext context, Friend friend, WidgetRef ref) {
  print('🔵 _showFriendDetails appelée pour ${friend.name}');
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) => Container(  // ← Utilise modalContext au lieu de context
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: Center(
              child: Text(
                friend.initials,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            friend.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          if (friend.phoneNumber != null)
            Text(
              friend.phoneNumber!,
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Créer une tab',
                  icon: Iconsax.add_circle,
                  onTap: () {
                    Navigator.pop(modalContext);  // ← modalContext
                    Navigator.push(
                      context,  // ← context parent pour la navigation
                      MaterialPageRoute(
                        builder: (context) => CreateTabScreen(preSelectedFriend: friend),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Supprimer',
                  icon: Iconsax.trash,
                  isDestructive: true,
                  onTap: () => _handleDeleteFriend(modalContext, friend, ref, context),  // ← Passe les 2 contexts
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Future<void> _handleDeleteFriend(
  BuildContext modalContext,  // ← Context de la bottom sheet
  Friend friend, 
  WidgetRef ref,
  BuildContext parentContext,  // ← Context parent pour le SnackBar
) async {
  print('🔵 DÉBUT _handleDeleteFriend pour ${friend.id}');
  Navigator.pop(modalContext);  // ← Ferme la bottom sheet avec son propre context
  await Future.delayed(const Duration(milliseconds: 300));
  
  if (!parentContext.mounted) {
    print('⚠️ Parent context non monté après délai');
    return;
  }
  
  final confirmed = await showDialog<bool>(
    context: parentContext,  // ← Utilise le parent context pour le dialog
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Supprimer ?', style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        'Supprimer ${friend.name} ?',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Non', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Oui', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );

  print('🔵 Confirmation: $confirmed');

  if (confirmed != true || !parentContext.mounted) {
    print('⚠️ Annulé ou context non monté');
    return;
  }

  try {
    print('🔥 APPEL deleteFriend(${friend.id})');
    
    await ref.read(friendsNotifierProvider.notifier).deleteFriend(friend.id);
    
    print('✅ deleteFriend terminé avec succès');
    
    if (parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('✅ Supprimé'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e, stackTrace) {
    print('❌ ERREUR CATCH: $e');
    print('📍 StackTrace: $stackTrace');
    if (parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Ajouter un ami', style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le nom est requis'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          await ref.read(friendsNotifierProvider.notifier).addFriend({
                            'name': nameController.text.trim(),
                            if (phoneController.text.isNotEmpty)
                              'phoneNumber': phoneController.text.trim(),
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${nameController.text} ajouté !'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                      )
                    : const Text('Ajouter', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(Iconsax.people, size: 36, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun ami',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoute des amis pour créer des tabs',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final String searchQuery;
  final VoidCallback onTap;
  
  const _FriendCard({
    required this.friend,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.card(),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      friend.initials,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      if (friend.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          friend.phoneNumber!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3, size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDestructive ? AppColors.error.withOpacity(0.1) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDestructive ? AppColors.error : AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isDestructive ? AppColors.error : AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}