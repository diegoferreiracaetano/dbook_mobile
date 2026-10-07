import 'package:flutter/material.dart';

import 'dbook_status_placeholder.dart';

/// Estado vazio de uma lista ou tabela ("nenhum resultado"). Camada fina
/// sobre [DbookStatusPlaceholder]: o bloco visual é um só em todo o app.
class DbookEmptyState extends StatelessWidget {
  const DbookEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return DbookStatusPlaceholder(
      icon: icon,
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
