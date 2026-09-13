import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

/// Carrossel horizontal com um card por região (foto do primeiro destino
/// daquela região + o nome da região) — usado na Home. Diferente da
/// Explore, aqui não filtra nada na própria tela: tocar um card leva pro
/// [onSelectRegion], que quem monta esta página decide o que fazer com
/// isso (levar pra aba Explore já com aquela região selecionada, no caso
/// do app).
class RegionCarousel extends StatelessWidget {
  const RegionCarousel({
    super.key,
    required this.destinations,
    required this.onSelectRegion,
  });

  final List<Destination> destinations;
  final ValueChanged<String> onSelectRegion;

  @override
  Widget build(BuildContext context) {
    final regions = destinations.map((d) => d.region).toSet().toList()
      ..sort();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: DbookSpacing.md),
        itemBuilder: (context, index) {
          final region = regions[index];
          final photoUrl = destinations
              .firstWhere((d) => d.region == region)
              .photoUrl;

          return SizedBox(
            width: 160,
            child: DbookDestinationCard(
              title: region,
              background: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () => onSelectRegion(region),
            ),
          );
        },
      ),
    );
  }
}
