import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/flight_providers.dart';
import 'destination_grid_card.dart';

/// Aba Explore — lista os destinos conhecidos (`GET /destinations`, mesma
/// fonte da Home). Tocar um chama [onSelectDestination]; quem monta esta
/// página decide o que fazer com isso (pré-preencher a busca e voltar pra
/// Home, no caso do app).
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key, required this.onSelectDestination});

  final ValueChanged<Destination> onSelectDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(featuredDestinationsProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Explore'),
      body: switch (destinations) {
        AsyncData(:final value) => SingleChildScrollView(
          padding: const EdgeInsets.all(DbookSpacing.lg),
          child: DestinationCardGrid(
            destinations: value,
            onSelect: onSelectDestination,
          ),
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
