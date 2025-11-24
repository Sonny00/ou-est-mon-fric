import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/friend_model.dart';
import '../providers/tabs_provider.dart';
import '../../friends/providers/friends_provider.dart';
import '../../auth/providers/auth_provider.dart'; // ← AJOUTER


class CreateTabScreen extends ConsumerStatefulWidget {
  final Friend? preSelectedFriend;

 const CreateTabScreen({
    Key? key,
    this.preSelectedFriend, 
  }) : super(key: key);

  @override
  ConsumerState<CreateTabScreen> createState() => _CreateTabScreenState();
}

class _CreateTabScreenState extends ConsumerState<CreateTabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Friend? _selectedFriend;
  bool _iOwe = false; 
  String? _imagePath;
  bool _isLoading = false;
  DateTime? _selectedDeadline; 
  

  @override
  void initState() {
    super.initState();
    _selectedFriend = widget.preSelectedFriend;
  }


  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle tab'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: friendsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Text('Erreur: $error'),
        ),
        data: (friends) {
          if (friends.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélection : Qui doit à qui ?
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppStyles.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Qui doit à qui ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ToggleOption(
                                label: 'Ils me doivent',
                                icon: Iconsax.arrow_down_1,
                                isSelected: !_iOwe,
                                color: AppColors.success,
                                onTap: () => setState(() => _iOwe = false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ToggleOption(
                                label: 'Je leur dois',
                                icon: Iconsax.arrow_up_1,
                                isSelected: _iOwe,
                                color: AppColors.error,
                                onTap: () => setState(() => _iOwe = true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sélection d'ami
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppStyles.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Avec qui ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (_selectedFriend == null)
                          InkWell(
                            onTap: () => _showFriendPicker(friends),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Iconsax.user, color: AppColors.textSecondary),
                                  SizedBox(width: 12),
                                  Text(
                                    'Sélectionner un ami',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Iconsax.arrow_down_1, size: 20, color: AppColors.textTertiary),
                                ],
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: () => _showFriendPicker(friends),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accent),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _selectedFriend!.initials,
                                        style: const TextStyle(
                                          color: AppColors.background,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedFriend!.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (_selectedFriend!.phoneNumber != null)
                                          Text(
                                            _selectedFriend!.phoneNumber!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Iconsax.edit, size: 20, color: AppColors.accent),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Montant
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppStyles.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Montant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary.withOpacity(0.5),
                            ),
                            suffixText: '€',
                            suffixStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le montant est requis';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Montant invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppStyles.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Exemple: taxi, dîner, etc.',
                            hintStyle: const TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.accent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La description est requise';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Photo (optionnel)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppStyles.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photo (optionnel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _imagePath == null ? Iconsax.camera : Iconsax.tick_circle,
                                  color: _imagePath == null ? AppColors.textSecondary : AppColors.success,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _imagePath == null ? 'Ajouter une photo' : 'Photo ajoutée',
                                    style: TextStyle(
                                      color: _imagePath == null ? AppColors.textSecondary : AppColors.success,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (_imagePath != null)
                                  IconButton(
                                    icon: const Icon(Iconsax.trash, size: 20, color: AppColors.error),
                                    onPressed: () => setState(() => _imagePath = null),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

// ⭐ Date limite (optionnel)
Container(
  padding: const EdgeInsets.all(16),
  decoration: AppStyles.card(),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Date limite (optionnel)',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: _selectDeadline,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.calendar,
                color: _selectedDeadline != null 
                    ? AppColors.accent 
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDeadline != null
                      ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                      : 'Aucune deadline',
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedDeadline != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (_selectedDeadline != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDeadline = null;
                    });
                  },
                  child: const Icon(
                    Iconsax.close_circle,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 24),

                  // Bouton créer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateTab,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : const Text(
                              'Créer la tab',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Icon(
              Iconsax.user_add,
              size: 36,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun ami',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez des amis pour créer des tabs',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFriendPicker(List<Friend> friends) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionner un ami',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          friend.initials,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      friend.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: friend.phoneNumber != null
                        ? Text(
                            friend.phoneNumber!,
                            style: const TextStyle(color: AppColors.textSecondary),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedFriend = friend);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }


  Future<void> _selectDeadline() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: AppColors.background,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null && picked != _selectedDeadline) {
    setState(() {
      _selectedDeadline = picked;
    });
  }
}

Future<void> _handleCreateTab() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedFriend == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez sélectionner un ami'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }
   
  final currentUser = ref.read(authStateProvider).value;
  final currentUserId = currentUser?.id ?? '';

  setState(() => _isLoading = true);

  try {
    final amount = double.parse(_amountController.text);
    
    // ⭐ IDENTIFIER LE VRAI USER ID DE L'AMI
    final friendUserId = _selectedFriend!.friendUserId ?? _selectedFriend!.userId;
    
    // Si friendUserId == currentUserId, alors l'ami c'est userId, sinon c'est friendUserId
    final actualFriendUserId = friendUserId == currentUserId 
        ? _selectedFriend!.userId 
        : friendUserId;
    
    print('🎯 === CRÉATION DE TAB ===');
    print('_iOwe (Je leur dois): $_iOwe');
    print('currentUserId: $currentUserId');
    print('Friend: ${_selectedFriend!.name}');
    print('actualFriendUserId: $actualFriendUserId');
    print('Amount: $amount€');
    
    final data = {
      // ⭐ CORRIGÉ : Utiliser actualFriendUserId
      'creditorId': _iOwe ? actualFriendUserId : currentUserId,
      'creditorName': _iOwe ? _selectedFriend!.name : currentUser?.name ?? 'Moi',
      'debtorId': _iOwe ? currentUserId : actualFriendUserId,
      'debtorName': _iOwe ? currentUser?.name ?? 'Moi' : _selectedFriend!.name,
      'amount': amount,
      'description': _descriptionController.text,
      if (_imagePath != null) 'proofImageUrl': _imagePath,
      if (_selectedDeadline != null) 
        'repaymentDeadline': _selectedDeadline!.toIso8601String(),
    };

    print('📤 Data envoyée:');
    print('   creditorId: ${data['creditorId']}');
    print('   creditorName: ${data['creditorName']}');
    print('   debtorId: ${data['debtorId']}');
    print('   debtorName: ${data['debtorName']}');
    print('   amount: ${data['amount']}');
    print('========================');

    await ref.read(tabsNotifierProvider.notifier).createTab(data);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tab créée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  } catch (e) {
    print('❌ Erreur création tab: $e');
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

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}