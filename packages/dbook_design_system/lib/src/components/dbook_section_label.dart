import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Rótulo de seção — texto pequeno em caixa alta, com ícone opcional. Ex.
/// "SUGESTÕES PRA VOCÊ" acima de uma lista de destinos.
class DbookSectionLabel extends StatelessWidget {
  const DbookSectionLabel({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DbookSpacing.xs),
        ],
        Text(text.toUpperCase(), style: style),
      ],
    );
  }
}
