import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/notification_providers.dart';
import 'notification_labels.dart';

/// Preferências por tipo e canal. Cada chave vale na hora; se o servidor
/// recusa, ela volta e um aviso explica.
class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Preferências de aviso'),
      body: prefs.when(
        loading: () => const DbookLoadingIndicator(),
        error: (error, _) => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          title: 'Não deu para carregar',
          message: error is DbookNetworkException
              ? error.message
              : 'Tente de novo.',
          actionLabel: 'Tentar de novo',
          onAction: () => ref.invalidate(preferencesNotifierProvider),
        ),
        data: (list) {
          final types = {for (final p in list) p.type}.toList();
          return ListView(
            children: [
              for (final type in types) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DbookSpacing.lg,
                    DbookSpacing.lg,
                    DbookSpacing.lg,
                    DbookSpacing.xs,
                  ),
                  child: Text(
                    notificationTypeLabel(type),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final p in list.where((p) => p.type == type))
                  SwitchListTile(
                    title: Text(notificationChannelLabel(p.channel)),
                    value: p.enabled,
                    onChanged: (value) async {
                      try {
                        await ref
                            .read(preferencesNotifierProvider.notifier)
                            .set(p.type, p.channel, enabled: value);
                      } on DbookNetworkException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
                      }
                    },
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
