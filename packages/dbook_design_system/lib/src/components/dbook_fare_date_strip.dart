import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Uma opção de data na [DbookFareDateStrip] — dia da semana, dia do mês e
/// a tarifa daquele dia.
@immutable
class DbookFareDateOption {
  const DbookFareDateOption({
    required this.dayLabel,
    required this.dateLabel,
    required this.price,
  });

  final String dayLabel;
  final String dateLabel;
  final String price;
}

/// Faixa horizontal de datas com a tarifa do dia — usada no topo dos
/// Resultados de busca pra trocar de data sem voltar pro formulário.
class DbookFareDateStrip extends StatelessWidget {
  const DbookFareDateStrip({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DbookFareDateOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: DbookSpacing.sm),
        itemBuilder: (context, index) {
          final option = options[index];
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
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: DbookSpacing.sm),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(DbookRadius.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${option.dayLabel} ${option.dateLabel}',
                    style: textTheme.labelSmall?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: DbookSpacing.xs),
                  Text(
                    option.price,
                    style: textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
