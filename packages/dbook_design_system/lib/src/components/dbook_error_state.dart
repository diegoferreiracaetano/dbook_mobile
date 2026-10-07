import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import 'dbook_status_placeholder.dart';

/// Estado de erro de uma lista ou tabela, com "Tentar de novo" quando quem
/// chama sabe repetir a operação. [message] é a do backend (front burro: o
/// app não inventa texto de erro). `liveRegion` faz o leitor de tela anunciar
/// o erro assim que ele aparece, sem o usuário ter que procurá-lo.
class DbookErrorState extends StatelessWidget {
  const DbookErrorState({
    super.key,
    required this.message,
    this.title = 'Algo deu errado',
    this.retryLabel = 'Tentar de novo',
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<DbookStatusColors>()!;

    return Semantics(
      liveRegion: true,
      child: DbookStatusPlaceholder(
        icon: Icons.error_outline,
        iconColor: statusColors.danger,
        title: title,
        message: message,
        actionLabel: onRetry == null ? null : retryLabel,
        onAction: onRetry,
      ),
    );
  }
}
