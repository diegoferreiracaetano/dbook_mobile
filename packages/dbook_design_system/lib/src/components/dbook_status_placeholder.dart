import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';
import 'dbook_button.dart';

/// Bloco de estado (ícone em círculo + título + mensagem + ação opcional)
/// reusado em estado vazio, estado de erro e estado de sucesso — muda só
/// ícone, cor e tamanho do círculo conforme quem chama, em vez de cada
/// tela reimplementar essa estrutura sozinha.
class DbookStatusPlaceholder extends StatelessWidget {
  const DbookStatusPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.circleSize = 72,
    this.iconSize = 32,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color? iconColor;
  final double circleSize;
  final double iconSize;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveIconColor, size: iconSize),
            ),
            const SizedBox(height: DbookSpacing.lg),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DbookSpacing.xs),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DbookSpacing.lg),
              DbookButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: DbookButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
