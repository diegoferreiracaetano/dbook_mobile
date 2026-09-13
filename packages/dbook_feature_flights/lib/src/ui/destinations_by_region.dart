import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/flight_providers.dart';
import 'destination_grid_card.dart';

/// Filtro de destinos por região — chips de seleção única ("Todos" +
/// uma por `region` distinta, em ordem alfabética) acima de uma grade
/// que mostra só os destinos da região escolhida. Usado só pela aba
/// Explore (a Home usa [RegionCarousel], sem filtro). Reage a
/// [prefillRegionProvider] pra pré-selecionar a região escolhida no
/// carrossel da Home, do mesmo jeito que a Home reage a
/// `prefillDestinationProvider` vindo da Explore.
class DestinationsByRegion extends ConsumerStatefulWidget {
  const DestinationsByRegion({
    super.key,
    required this.destinations,
    required this.onSelect,
  });

  final List<Destination> destinations;
  final ValueChanged<Destination> onSelect;

  @override
  ConsumerState<DestinationsByRegion> createState() =>
      _DestinationsByRegionState();
}

class _DestinationsByRegionState extends ConsumerState<DestinationsByRegion> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final regions = widget.destinations.map((d) => d.region).toSet().toList()
      ..sort();
    final labels = ['Todos', ...regions];

    ref.listen<String?>(prefillRegionProvider, (previous, next) {
      if (next == null) return;
      ref.read(prefillRegionProvider.notifier).set(null);
      final index = regions.indexOf(next);
      if (index == -1) return;
      setState(() => _selectedIndex = index + 1);
    });

    final selectedRegion = _selectedIndex == 0
        ? null
        : regions[_selectedIndex - 1];
    final filtered = selectedRegion == null
        ? widget.destinations
        : widget.destinations.where((d) => d.region == selectedRegion).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DbookSectionLabel(
          text: 'Destinos por região',
          icon: Icons.public_outlined,
        ),
        const SizedBox(height: DbookSpacing.md),
        DbookChipRow(
          labels: labels,
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: DbookSpacing.md),
        DestinationCardGrid(destinations: filtered, onSelect: widget.onSelect),
      ],
    );
  }
}
