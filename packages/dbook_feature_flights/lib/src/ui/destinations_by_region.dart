import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

import 'destination_grid_card.dart';

/// Filtro de destinos por região — chips de seleção única ("Todos" +
/// uma por `region` distinta, em ordem alfabética) acima de uma grade
/// que mostra só os destinos da região escolhida. É a única forma de
/// navegar por região no app (a Home não tem mais nenhum atalho pra
/// região — ter dois lugares fazendo a mesma coisa não ajudava).
class DestinationsByRegion extends StatefulWidget {
  const DestinationsByRegion({
    super.key,
    required this.destinations,
    required this.onSelect,
  });

  final List<Destination> destinations;
  final ValueChanged<Destination> onSelect;

  @override
  State<DestinationsByRegion> createState() => _DestinationsByRegionState();
}

class _DestinationsByRegionState extends State<DestinationsByRegion> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final regions = widget.destinations.map((d) => d.region).toSet().toList()
      ..sort();
    final labels = ['Todos', ...regions];

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
