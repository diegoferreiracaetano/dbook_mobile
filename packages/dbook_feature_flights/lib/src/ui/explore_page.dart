import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/flight_providers.dart';
import 'destination_grid_card.dart';

/// Aba Explore — lista os destinos conhecidos (`GET /destinations`, mesma
/// fonte da Home), organizados em dois grupos: "Principais destinos"
/// (`isPopular`, curadoria real do backend) e "Destinos por região" (um
/// grupo por `region`). Os dois grupos vêm da mesma lista já carregada por
/// [featuredDestinationsProvider] — nenhuma busca nova, só duas formas de
/// agrupar o que já chegou. Tocar um destino chama [onSelectDestination];
/// quem monta esta página decide o que fazer com isso (pré-preencher a
/// busca e voltar pra Home, no caso do app).
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key, required this.onSelectDestination});

  final ValueChanged<Destination> onSelectDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(featuredDestinationsProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Explore'),
      body: switch (destinations) {
        AsyncData(:final value) => _ExploreContent(
          destinations: value,
          onSelectDestination: onSelectDestination,
        ),
        AsyncError() => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'Não foi possível carregar',
          message: 'Tente de novo em instantes.',
          actionLabel: 'Tentar de novo',
          onAction: () => ref.invalidate(featuredDestinationsProvider),
        ),
        _ => const DbookLoadingIndicator(message: 'Carregando destinos...'),
      },
    );
  }
}

class _ExploreContent extends StatelessWidget {
  const _ExploreContent({
    required this.destinations,
    required this.onSelectDestination,
  });

  final List<Destination> destinations;
  final ValueChanged<Destination> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    final popular = destinations.where((d) => d.isPopular).toList();
    final byRegion = <String, List<Destination>>{};
    for (final destination in destinations) {
      byRegion.putIfAbsent(destination.region, () => []).add(destination);
    }
    final regions = byRegion.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (popular.isNotEmpty) ...[
            const DbookSectionLabel(
              text: 'Principais destinos',
              icon: Icons.star_outline,
            ),
            const SizedBox(height: DbookSpacing.md),
            DestinationCardGrid(
              destinations: popular,
              onSelect: onSelectDestination,
            ),
            const SizedBox(height: DbookSpacing.xl),
          ],
          for (final region in regions) ...[
            DbookSectionLabel(text: region, icon: Icons.public_outlined),
            const SizedBox(height: DbookSpacing.md),
            DestinationCardGrid(
              destinations: byRegion[region]!,
              onSelect: onSelectDestination,
            ),
            const SizedBox(height: DbookSpacing.xl),
          ],
        ],
      ),
    );
  }
}
