// lib/features/friends/screens/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/friend_model.dart';
import '../providers/friends_provider.dart';
import '../../tabs/screens/create_tab_screen.dart';
import 'add_friend_screen.dart';
import 'friend_requests_screen.dart';

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
    final friendsAsync = ref.watch(friendsProvider);
    
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
          // ⭐ NOUVEAU : Badge invitations
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsScreen(),
                    ),
                  );
                },
              ),
              // Badge rouge avec le nombre
              Consumer(
                builder: (context, ref, child) {
                  final requests = ref.watch(receivedRequestsProvider);
                  return requests.when(
                    data: (requests) {
                      if (requests.isEmpty) return const SizedBox();
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            requests.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  );
                },
              ),
            ],
          ),
          
          // Bouton recherche
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
                onPressed: () => ref.invalidate(friendsProvider),
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
                    ref.invalidate(friendsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      return _FriendCard(
                        friend: filteredFriends[index],
                        searchQuery: _searchQuery,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFriendScreen(),
                      ),
                    );
                  },
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
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
                      Navigator.pop(modalContext);
                      Navigator.push(
                        context,
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
                    onTap: () => _handleDeleteFriend(modalContext, friend, ref, context),
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
    BuildContext modalContext,
    Friend friend, 
    WidgetRef ref,
    BuildContext parentContext,
  ) async {
    Navigator.pop(modalContext);
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!parentContext.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: parentContext,
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

    if (confirmed != true || !parentContext.mounted) return;

    try {
      await ref.read(friendsNotifierProvider.notifier).deleteFriend(friend.id);
      
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('Ami supprimé'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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