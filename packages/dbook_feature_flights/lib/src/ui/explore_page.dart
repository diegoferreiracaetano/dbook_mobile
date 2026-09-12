import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

import '../data/known_airports.dart';
import 'destination_gradient.dart';

/// Aba Explore — lista os destinos conhecidos (mesma fonte da Home, o
/// backend não expõe um catálogo de destinos). Tocar um chama
/// [onSelectDestination]; quem monta esta página decide o que fazer com
/// isso (pré-preencher a busca e voltar pra Home, no caso do app).
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key, required this.onSelectDestination});

  final ValueChanged<KnownAirport> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DbookAppBar(title: 'Explore'),
      body: GridView.builder(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: DbookSpacing.md,
          crossAxisSpacing: DbookSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemCount: knownAirports.length,
        itemBuilder: (context, index) {
          final airport = knownAirports[index];
          return DbookDestinationCard(
            title: airport.city,
            subtitle: airport.country,
            background: BoxDecoration(gradient: destinationGradient(index)),
            onTap: () => onSelectDestination(airport),
          );
        },
      ),
    );
  }
}
