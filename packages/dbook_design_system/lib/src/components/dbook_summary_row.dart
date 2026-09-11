import 'package:flutter/material.dart';

import '../tokens/dbook_spacing.dart';

/// Linha de resumo rótulo↔valor — ex. "Order Summary" no Pagamento ou o
/// resumo da reserva. Use [emphasize] na linha de total.
class DbookSummaryRow extends StatelessWidget {
  const DbookSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasize
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DbookSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
