import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/favorite_destinations_notifier.dart';
import 'destination_gradient.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

/// Grade de `DestinationCard` com altura de célula calculada em vez de um
/// `childAspectRatio` fixo — um valor fixo só bate certo numa largura de
/// tela específica; em qualquer outra, ou sobra espaço vazio abaixo do
/// texto (célula alta demais) ou o texto estoura (célula baixa demais).
/// Aqui a altura é exatamente foto (3:2) + bloco de texto (cidade+país,
/// medido a partir dos tokens de tipografia: `labelLarge` 20 + `bodySmall`
/// 16 + padding vertical 12 = 48), então nunca sobra nem falta espaço.
class DestinationCardGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final destination = destinations[index];
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isFavorite =
        ref.watch(favoriteDestinationsProvider).value?.contains(
          destination.iataCode,
        ) ??
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
                      onTap: () => ref
                          .read(favoriteDestinationsProvider.notifier)
                          .toggle(destination.iataCode),
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
                      if (lowestPrice != null)
                        Text(
                          'from ${_priceFormat.format(lowestPrice)}',
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

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.xs),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
