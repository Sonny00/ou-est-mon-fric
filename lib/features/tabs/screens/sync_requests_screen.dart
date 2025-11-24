// lib/features/tabs/screens/sync_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart'; // ⭐ CHANGER CET IMPORT
import '../../../data/models/tab_sync_request_model.dart';
import '../providers/tabs_provider.dart';

class SyncRequestsScreen extends ConsumerWidget {
  const SyncRequestsScreen({super.key});

 @override
Widget build(BuildContext context, WidgetRef ref) {
  final syncRequests = ref.watch(pendingSyncRequestsProvider);

  print('🔔 Écran notifications ouvert');

  return Scaffold(
    appBar: AppBar(
      title: const Text('Demandes de synchronisation'),
    ),
    body: syncRequests.when(
      data: (requests) {
        print('✅ Données reçues: ${requests.length} demandes'); // ⭐ AJOUTER
        for (var req in requests) {
          print('  - ${req.message}'); // ⭐ AJOUTER
        }
        
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.tick_circle, size: 64, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  'Aucune demande en attente',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return _SyncRequestCard(request: requests[index]);
          },
        );
      },
      loading: () {
        print('⏳ Chargement...'); // ⭐ AJOUTER
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        print('❌ Erreur: $error'); // ⭐ AJOUTER
        return Center(child: Text('Erreur: $error'));
      },
    ),
  );
}
}
class _SyncRequestCard extends ConsumerWidget {
  final TabSyncRequest request;
  
  const _SyncRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRepayment = request.type == 'repayment';
    final tabData = request.tabData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRepayment 
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRepayment ? Iconsax.money_recive : Iconsax.document_text,
                      size: 14,
                      color: isRepayment ? AppColors.accent : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isRepayment ? 'Remboursement' : 'Nouveau tab',
                      style: TextStyle(
                        color: isRepayment ? AppColors.accent : AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (tabData != null)
                Text(
                  '${tabData.amount.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.message ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (tabData != null) ...[
            const SizedBox(height: 8),
            Text(
              tabData.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tabData.creditorName} ← ${tabData.debtorName}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAccept(context, ref),
                  icon: const Icon(Iconsax.tick_circle),
                  label: Text(isRepayment ? 'Confirmer' : 'Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleReject(context, ref),
                  icon: const Icon(Iconsax.close_circle),
                  label: const Text('Refuser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(tabsNotifierProvider.notifier).respondToSyncRequest(
        request.id,
        'accept',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              request.type == 'repayment' 
                ? 'Remboursement confirmé !' 
                : 'Tab synchronisé !',
            ),
            backgroundColor: AppColors.accent,
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
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputReason = '';
        return AlertDialog(
          title: const Text('Refuser'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Raison du refus (optionnel)',
            ),
            maxLines: 3,
            onChanged: (value) => inputReason = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, inputReason),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );

    if (reason == null) return;

    try {
      await ref.read(tabsNotifierProvider.notifier).respondToSyncRequest(
        request.id,
        'reject',
        rejectionReason: reason.isEmpty ? null : reason,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande refusée'),
            backgroundColor: AppColors.error,
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
  }
}