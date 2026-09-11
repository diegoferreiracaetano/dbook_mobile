import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Um item de legenda (swatch quadrado + rótulo) — usado, por exemplo, na
/// legenda do mapa de assento (livre/selecionado/ocupado).
class DbookLegendItem extends StatelessWidget {
  const DbookLegendItem({
    super.key,
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;

  /// Quando true, desenha só o contorno (ex.: "livre") em vez de preencher.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: outlined ? null : color,
            border: outlined ? Border.all(color: color) : null,
            borderRadius: BorderRadius.circular(DbookRadius.xs),
          ),
        ),
        const SizedBox(width: DbookSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
