import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

import 'destination_grid_card.dart';

/// Listagem real de destinos de UMA região — o que tocar um card do
/// [RegionCarousel] na Home abre. [destinations] já vem filtrada por quem
/// monta esta página (a mesma lista de [featuredDestinationsProvider] que
/// a Home já tem carregada — sem fetch novo), então esta tela não sabe
/// nada de região além do nome pro título; tocar um destino aqui chama
/// [onSelectDestination], igual à grade "Principais destinos" do Explore.
class RegionDestinationsPage extends StatelessWidget {
  const RegionDestinationsPage({
    super.key,
    required this.region,
    required this.destinations,
    required this.onSelectDestination,
  });

  final String region;
  final List<Destination> destinations;
  final ValueChanged<Destination> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DbookAppBar(title: region),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: DestinationCardGrid(
          destinations: destinations,
          onSelect: onSelectDestination,
        ),
      ),
    );
  }
}
