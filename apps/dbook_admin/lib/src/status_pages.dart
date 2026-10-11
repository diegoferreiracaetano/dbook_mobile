import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 404: o endereço não existe. Fora do shell, para funcionar até sem sessão.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: DbookStatusPlaceholder(
        icon: Icons.search_off,
        title: l10n.notFoundTitle,
        message: l10n.notFoundMessage,
        actionLabel: l10n.goHome,
        onAction: () => context.go('/'),
      ),
    );
  }
}

/// 403: a área existe, mas o papel de quem está logado não a inclui.
class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DbookStatusPlaceholder(
      icon: Icons.lock_outline,
      iconColor: Theme.of(context).colorScheme.error,
      title: l10n.forbiddenTitle,
      message: l10n.forbiddenMessage,
      actionLabel: l10n.goHome,
      onAction: () => context.go('/'),
    );
  }
}
