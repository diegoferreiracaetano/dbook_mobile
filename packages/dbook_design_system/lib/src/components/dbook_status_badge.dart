import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Status semântico de uma reserva — cada valor mapeia pra um par de cores
/// (fundo claro + texto saturado) definido no tema.
enum DbookStatus { confirmed, pending, cancelled }

/// Badge (pill pequena) de status — ex.: "Confirmada"/"Pendente"/"Cancelada"
/// na lista de reservas.
class DbookStatusBadge extends StatelessWidget {
  const DbookStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  final DbookStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<DbookStatusColors>()!;

    final (background, foreground) = switch (status) {
      DbookStatus.confirmed => (
        statusColors.successContainer,
        statusColors.success,
      ),
      DbookStatus.pending => (
        statusColors.warningContainer,
        statusColors.warning,
      ),
      DbookStatus.cancelled => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
