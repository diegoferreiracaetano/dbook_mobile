import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'destinations.dart';

/// O início: saudação e atalhos para as áreas que o papel de quem está logado
/// pode abrir (o mesmo filtro do menu).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(staffProfileProvider);
    final shortcuts = visibleDestinations(profile).where((d) => d.path != '/');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeGreeting(profile?.name ?? ''),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: DbookSpacing.xs),
          Text(
            l10n.homeWelcomeMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DbookSpacing.xl),
          Wrap(
            spacing: DbookSpacing.md,
            runSpacing: DbookSpacing.md,
            children: [
              for (final destination in shortcuts)
                SizedBox(
                  width: 220,
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DbookRadius.lg),
                      onTap: () => context.go(destination.path),
                      child: Padding(
                        padding: const EdgeInsets.all(DbookSpacing.lg),
                        child: Row(
                          children: [
                            Icon(destination.icon),
                            const SizedBox(width: DbookSpacing.md),
                            Expanded(child: Text(destination.label(l10n))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
