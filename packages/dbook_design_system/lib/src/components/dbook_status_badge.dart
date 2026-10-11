import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Status semântico de uma reserva — cada valor mapeia pra um par de cores
/// (fundo claro + texto saturado) definido no tema.
enum DbookStatus { confirmed, pending, cancelled, unknown }

/// Badge (pill pequena) de status — ex.: "Confirmada"/"Pendente"/"Cancelada"
/// na lista de reservas. Com [showIcon] o status deixa de depender só da cor
/// (acessibilidade: daltonismo): o portal liga, o app de clientes não.
class DbookStatusBadge extends StatelessWidget {
  const DbookStatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.showIcon = false,
  });

  final DbookStatus status;
  final String label;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<DbookStatusColors>()!;

    final (background, foreground, icon) = switch (status) {
      DbookStatus.confirmed => (
        statusColors.successContainer,
        statusColors.success,
        Icons.check_circle_outline,
      ),
      DbookStatus.pending => (
        statusColors.warningContainer,
        statusColors.warning,
        Icons.schedule,
      ),
      DbookStatus.cancelled => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.error,
        Icons.cancel_outlined,
      ),
      DbookStatus.unknown => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
        Icons.help_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.sm,
        vertical: DbookSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: DbookSpacing.xs),
          ],
          // Flexible: em coluna estreita (tabela do portal) o rótulo corta com
          // reticências em vez de estourar a linha.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
