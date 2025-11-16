// lib/features/friends/screens/add_friend_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/friends_provider.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter un ami'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(
              icon: Icon(Iconsax.user),
              text: 'Contact simple',
            ),
            Tab(
              icon: Icon(Iconsax.verify),
              text: 'Ami vérifié',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ContactTab(),
          _VerifiedFriendTab(),
        ],
      ),
    );
  }
}

// ========================================
// ONGLET 1 : CONTACT SIMPLE (NON-VÉRIFIÉ)
// ========================================

class _ContactTab extends ConsumerStatefulWidget {
  const _ContactTab();

  @override
  ConsumerState<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends ConsumerState<_ContactTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.user, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contact simple sans compte OuEstMonFric',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nom
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Iconsax.user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Téléphone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Téléphone (optionnel)',
                prefixIcon: const Icon(Iconsax.call),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Email (optionnel)',
                prefixIcon: const Icon(Iconsax.sms),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bouton créer
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleCreateContact,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Icon(Iconsax.add),
              label: Text(_isLoading ? 'Ajout...' : 'Ajouter le contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        if (_phoneController.text.isNotEmpty)
          'phoneNumber': _phoneController.text.trim(),
        if (_emailController.text.isNotEmpty)
          'email': _emailController.text.trim(),
      };

      await ref.read(friendsNotifierProvider.notifier).createFriend(data);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact ajouté !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// =====================================
// ONGLET 2 : AMI VÉRIFIÉ (PAR TAG)
// =====================================

class _VerifiedFriendTab extends ConsumerStatefulWidget {
  const _VerifiedFriendTab();

  @override
  ConsumerState<_VerifiedFriendTab> createState() => _VerifiedFriendTabState();
}

class _VerifiedFriendTabState extends ConsumerState<_VerifiedFriendTab> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController(); // ⭐ AJOUTÉ
  bool _isLoading = false;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.verify, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ami vérifié',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ajoutez un ami via son tag unique',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⭐ Champ TAG
            TextFormField(
              controller: _tagController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Tag de votre ami',
                hintText: 'Ex: Sonny#7842',
                prefixIcon: const Icon(Iconsax.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Format: Nom#1234',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le tag est requis';
                }
                final regex = RegExp(r'^.+#\d{4}$');
                if (!regex.hasMatch(value)) {
                  return 'Format invalide (ex: Nom#1234)';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Bouton envoyer invitation
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSendRequest,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Icon(Iconsax.send_1),
              label: Text(_isLoading ? 'Envoi...' : 'Envoyer l\'invitation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Info supplémentaire
            const Text(
              'Votre ami recevra une notification et pourra accepter votre invitation.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ⭐ Envoyer l'invitation par TAG
      await ref.read(friendsNotifierProvider.notifier).sendFriendRequestByTag(
            _tagController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation envoyée !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}