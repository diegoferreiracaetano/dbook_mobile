import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Tom semântico da [DbookInlineStatusBanner].
enum DbookBannerTone { info, success, warning }

/// Faixa de status inline — ícone + texto numa tarja colorida, usada pra
/// avisos curtos embutidos no fluxo (ex. "Disponibilidade em tempo real").
class DbookInlineStatusBanner extends StatelessWidget {
  const DbookInlineStatusBanner({
    super.key,
    required this.message,
    this.tone = DbookBannerTone.info,
    this.icon,
  });

  final String message;
  final DbookBannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<DbookStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground, defaultIcon) = switch (tone) {
      DbookBannerTone.info => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        Icons.info_outline,
      ),
      DbookBannerTone.success => (
        statusColors.successContainer,
        statusColors.success,
        Icons.check_circle_outline,
      ),
      DbookBannerTone.warning => (
        statusColors.warningContainer,
        statusColors.warning,
        Icons.warning_amber_outlined,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.md,
        vertical: DbookSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DbookRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? defaultIcon, color: foreground, size: 18),
          const SizedBox(width: DbookSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
