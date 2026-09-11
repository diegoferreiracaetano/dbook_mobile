import 'package:flutter/material.dart';

/// Preço em tipografia grande e em destaque — reusado em Detalhe do voo,
/// Revisar reserva e Bilhete, com uma legenda opcional (ex. "por pessoa").
class DbookPriceDisplay extends StatelessWidget {
  const DbookPriceDisplay({super.key, required this.amount, this.caption});

  final String amount;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amount,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
