import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

import 'destination_grid_card.dart';

/// Agrupa [destinations] por `region` e renderiza uma seção (rótulo +
/// grade) por grupo, ordenadas alfabeticamente. Usado pela Home e pela
/// aba Explore — as duas recebem a mesma lista já carregada por
/// `featuredDestinationsProvider` e só agrupam de um jeito diferente, sem
/// buscar nada novo.
class DestinationsByRegion extends StatelessWidget {
  const DestinationsByRegion({
    super.key,
    required this.destinations,
    required this.onSelect,
  });

  final List<Destination> destinations;
  final ValueChanged<Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    final byRegion = <String, List<Destination>>{};
    for (final destination in destinations) {
      byRegion.putIfAbsent(destination.region, () => []).add(destination);
    }
    final regions = byRegion.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final region in regions) ...[
          DbookSectionLabel(text: region, icon: Icons.public_outlined),
          const SizedBox(height: DbookSpacing.md),
          DestinationCardGrid(
            destinations: byRegion[region]!,
            onSelect: onSelect,
          ),
          const SizedBox(height: DbookSpacing.xl),
        ],
      ],
    );
  }
}
