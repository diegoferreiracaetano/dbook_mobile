import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/favorite_destinations_notifier.dart';
import '../state/flight_providers.dart';
import 'destination_grid_card.dart';

/// Aba "Favoritos": os destinos que o cliente marcou com o coração (salvos no
/// servidor), em grade. Reaproveita a lista já carregada de destinos; sem
/// nenhum favorito, mostra o estado vazio com a instrução de como encher.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key, required this.onSelectDestination});

  final ValueChanged<Destination> onSelectDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteDestinationsProvider);
    final destinations = ref.watch(featuredDestinationsProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Favoritos'),
      body: switch ((favorites, destinations)) {
        (AsyncData(value: final codes), AsyncData(value: final all)) =>
          _content(
            context,
            all.where((d) => codes.contains(d.iataCode)).toList(),
          ),
        (AsyncError(), _) || (_, AsyncError()) => DbookStatusPlaceholder(
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          title: 'Não foi possível carregar',
          message: 'Tente de novo em instantes.',
          actionLabel: 'Tentar de novo',
          onAction: () {
            ref.invalidate(favoriteDestinationsProvider);
            ref.invalidate(featuredDestinationsProvider);
          },
        ),
        _ => const DbookLoadingIndicator(message: 'Carregando favoritos...'),
      },
    );
  }

  Widget _content(BuildContext context, List<Destination> saved) {
    if (saved.isEmpty) {
      return const DbookStatusPlaceholder(
        icon: Icons.favorite_border,
        title: 'Sua lista está vazia',
        message: 'Toque no coração de um destino para guardá-lo aqui e voltar a ele depois.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(DbookSpacing.lg),
      children: [
        DestinationCardGrid(destinations: saved, onSelect: onSelectDestination),
      ],
    );
  }
}
