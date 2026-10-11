import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/destination_reviews_notifier.dart' show isLoggedInProvider;
import '../state/favorite_destinations_notifier.dart';
import '../state/flight_providers.dart';
import 'destination_detail_page.dart';
import 'destination_gradient.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

/// Grade de `DestinationCard` com altura de célula calculada em vez de um
/// `childAspectRatio` fixo — um valor fixo só bate certo numa largura de
/// tela específica; em qualquer outra, ou sobra espaço vazio abaixo do
/// texto (célula alta demais) ou o texto estoura (célula baixa demais).
/// Aqui a altura é exatamente foto (3:2) + bloco de texto (cidade+país,
/// medido a partir dos tokens de tipografia: `labelLarge` 20 + `bodySmall`
/// 16 + padding vertical 12 = 48), então nunca sobra nem falta espaço.
///
/// Nunca oferece como destino o aeroporto de onde a busca já está saindo
/// ([searchOriginProvider]): tocar nele montaria uma busca de uma cidade
/// pra ela mesma, que nunca devolve voo. É o único lugar que filtra isso
/// porque Home, Explore e a listagem por região passam todas por aqui.
class DestinationCardGrid extends ConsumerWidget {
  const DestinationCardGrid({
    super.key,
    required this.destinations,
    required this.onSelect,
    this.crossAxisCount = 2,
  });

  final List<Destination> destinations;
  final ValueChanged<Destination> onSelect;
  final int crossAxisCount;

  static const _textBlockHeight = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originIataCode = ref.watch(searchOriginProvider)?.origin.iataCode;
    final offered = destinations
        .where((destination) => destination.iataCode != originIataCode)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = DbookSpacing.md * (crossAxisCount - 1);
        final cellWidth =
            (constraints.maxWidth - totalSpacing) / crossAxisCount;
        final cellHeight = cellWidth * 2 / 3 + _textBlockHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: DbookSpacing.md,
            crossAxisSpacing: DbookSpacing.md,
            mainAxisExtent: cellHeight,
          ),
          itemCount: offered.length,
          itemBuilder: (context, index) {
            final destination = offered[index];
            return DestinationCard(
              destination: destination,
              onTap: () => onSelect(destination),
            );
          },
        );
      },
    );
  }
}

/// Card de destino com foto em cima e nome/país abaixo (não sobreposto,
/// diferente do `DbookDestinationCard` do design system) — usado na grade
/// "Destinos em destaque" da Home e na aba Explore. Foto ganha um botão de
/// favorito (canto superior direito, local — sem endpoint de favoritos no
/// backend) e o rodapé mostra o menor preço real do [destination], já
/// vindo pronto de `GET /destinations` (sem busca por card).
class DestinationCard extends ConsumerWidget {
  const DestinationCard({super.key, required this.destination, this.onTap});

  final Destination destination;
  final VoidCallback? onTap;

  /// Favoritar exige sessão (é do servidor). Sem sessão ou sem rede a mudança
  /// **não acontece** e uma mensagem explica o motivo: nada é guardado para
  /// sincronizar depois sem a pessoa saber.
  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

    if (!ref.read(isLoggedInProvider)) {
      say('Entre na sua conta para salvar destinos favoritos.');
      return;
    }
    try {
      await ref
          .read(favoriteDestinationsProvider.notifier)
          .toggle(destination.iataCode);
    } on DbookNetworkException catch (error) {
      say(
        error.code == 'FAVORITES_LIMIT'
            ? 'Você atingiu o limite de 200 favoritos. Remova algum para salvar outro.'
            : error is DbookUnknownNetworkException
            ? 'Sem conexão: não deu para salvar. Tente de novo quando a rede voltar.'
            : 'Não foi possível salvar o favorito. Tente de novo.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isFavorite =
        ref
            .watch(favoriteDestinationsProvider)
            .value
            ?.contains(destination.iataCode) ??
        false;
    final lowestPrice = destination.lowestPrice;

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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: destinationBackground(destination),
                    ),
                  ),
                  Positioned(
                    top: DbookSpacing.xs,
                    right: DbookSpacing.xs,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: () => _toggleFavorite(context, ref),
                    ),
                  ),
                ],
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
                    destination.city,
                    style: textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          destination.country,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (destination.averageRating != null) ...[
                        // a nota abre as avaliações do destino; o resto do
                        // card segue buscando voos como sempre (M19)
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DestinationDetailPage(
                                destination: destination,
                              ),
                            ),
                          ),
                          child: Semantics(
                            button: true,
                            label: 'Ver avaliações de ${destination.city}',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: DbookSpacing.xxs),
                                Text(
                                  destination.averageRating!.toStringAsFixed(1),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: DbookSpacing.xs),
                      ],
                      if (lowestPrice != null)
                        Text(
                          'a partir de ${_priceFormat.format(lowestPrice)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
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

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Alvo de toque de 44 dp (mínimo de acessibilidade); o círculo visível
    // continua pequeno para não cobrir a foto.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Material(
            color: colorScheme.surface.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(DbookSpacing.xs),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFavorite
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
