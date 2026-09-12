import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

import '../data/known_airports.dart';
import 'destination_gradient.dart';

/// Card de destino com foto em cima e nome/país abaixo (não sobreposto,
/// diferente do `DbookDestinationCard` do design system) — usado na grade
/// "Destinos em destaque" da Home e na aba Explore.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.airport,
    required this.index,
    this.onTap,
  });

  final KnownAirport airport;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DbookRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: destinationBackground(airport, index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DbookSpacing.sm,
                DbookSpacing.xs,
                DbookSpacing.sm,
                DbookSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airport.city,
                    style: textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    airport.country,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
