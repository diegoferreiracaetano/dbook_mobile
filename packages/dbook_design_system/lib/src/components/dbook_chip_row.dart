import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Faixa horizontal de chips de seleção única — usada pra filtrar uma
/// lista por categoria (ex.: região de um destino). Mesmo padrão visual
/// do [DbookFareDateStrip] (chip cheio quando selecionado), mas com só
/// texto, sem estrutura de data/preço.
class DbookChipRow extends StatelessWidget {
  const DbookChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: DbookSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final background = isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLow;
          final foreground = isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface;

          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(DbookRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DbookSpacing.md,
                vertical: DbookSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(DbookRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
