import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Linha de resultado de busca de voo — horário, duração e preço, com
/// contorno de destaque quando [selected].
class DbookFlightResultTile extends StatelessWidget {
  const DbookFlightResultTile({
    super.key,
    required this.timeRange,
    required this.durationLabel,
    required this.price,
    this.selected = false,
    this.onTap,
  });

  final String timeRange;
  final String durationLabel;
  final String price;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(DbookRadius.lg);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected
            ? BorderSide(color: colorScheme.primary, width: 1.6)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeRange, style: textTheme.titleSmall),
                  Text(durationLabel, style: textTheme.bodySmall),
                ],
              ),
              Text(
                price,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
