import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_stays/dbook_feature_stays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _price = NumberFormat.currency(symbol: r'$');

/// Quantos destinos alimentam a vitrine: cada um é uma busca real no
/// servidor, então o número fica pequeno.
const _showcaseDestinations = 3;

/// Vitrine da Home: carrossel de hotéis e pacotes voo + hotel. Mora no app
/// porque junta duas features (voos e hotéis), que não se importam. Tudo vem
/// do servidor: hotéis da busca e o preço de voo do destino; o app não soma
/// nem inventa preço de pacote, só mostra os dois lado a lado.
class HomeStaysSection extends ConsumerWidget {
  const HomeStaysSection({
    super.key,
    required this.destinations,
    required this.isLoggedIn,
    required this.onRequireLogin,
    required this.onCheckout,
    required this.onSearchFlights,
  });

  final List<Destination> destinations;
  final bool isLoggedIn;
  final VoidCallback onRequireLogin;
  final void Function(StayCheckout checkout) onCheckout;
  final void Function(Destination destination) onSearchFlights;

  void _openHotel(BuildContext context, FeaturedStay stay) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => StayDetailPage(
          hotelId: stay.hotel.id,
          search: stay.search,
          isLoggedIn: isLoggedIn,
          onRequireLogin: onRequireLogin,
          onCheckout: onCheckout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = destinations
        .where((d) => d.isPopular)
        .take(_showcaseDestinations)
        .toList();
    final byCode = <String, List<FeaturedStay>>{
      for (final d in shown)
        d.iataCode:
            ref.watch(featuredStaysProvider(d.iataCode)).value ?? const [],
    };
    final hotels = byCode.values.expand((list) => list).toList();
    if (hotels.isEmpty) return const SizedBox.shrink();

    final packages = [
      for (final d in shown)
        if (d.lowestPrice != null && byCode[d.iataCode]!.isNotEmpty)
          (destination: d, stay: byCode[d.iataCode]!.first),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DbookSectionLabel(
          text: 'Hotéis em destaque',
          icon: Icons.hotel_outlined,
        ),
        const SizedBox(height: DbookSpacing.md),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length,
            separatorBuilder: (_, _) => const SizedBox(width: DbookSpacing.md),
            itemBuilder: (context, index) => _HotelCard(
              stay: hotels[index],
              onTap: () => _openHotel(context, hotels[index]),
            ),
          ),
        ),
        if (packages.isNotEmpty) ...[
          const SizedBox(height: DbookSpacing.xl),
          const DbookSectionLabel(
            text: 'Pacotes voo + hotel',
            icon: Icons.luggage_outlined,
          ),
          const SizedBox(height: DbookSpacing.md),
          for (final item in packages) ...[
            _PackageCard(
              destination: item.destination,
              stay: item.stay,
              onFlights: () => onSearchFlights(item.destination),
              onHotel: () => _openHotel(context, item.stay),
            ),
            const SizedBox(height: DbookSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.stay, required this.onTap});

  final FeaturedStay stay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hotel = stay.hotel;
    final from = hotel.fromPrice;
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: DbookPhoto(
                  url: hotel.photoUrl,
                  icon: Icons.hotel_outlined,
                  semanticLabel: 'Foto do ${hotel.name}',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(DbookSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${'★' * hotel.stars}  ${hotel.city}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (from != null) ...[
                      const SizedBox(height: DbookSpacing.xs),
                      Text(
                        '${_price.format(from)} · ${stay.search.nights} noites',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.destination,
    required this.stay,
    required this.onFlights,
    required this.onHotel,
  });

  final Destination destination;
  final FeaturedStay stay;
  final VoidCallback onFlights;
  final VoidCallback onHotel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<DbookBrandColors>()!;
    final hotelFrom = stay.hotel.fromPrice;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 120,
            child: DbookPhoto(
              url: destination.photoUrl,
              icon: Icons.landscape_outlined,
              semanticLabel: 'Foto de ${destination.city}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.city, style: theme.textTheme.titleMedium),
                const SizedBox(height: DbookSpacing.xs),
                Text(
                  'Voo a partir de ${_price.format(destination.lowestPrice)}'
                  '${hotelFrom == null ? '' : ' · hotel a partir de ${_price.format(hotelFrom)}'}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: DbookSpacing.xs),
                Text(
                  'Cada item é reservado e pago separadamente.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: DbookSpacing.md),
                Row(
                  children: [
                    Expanded(
                      // Branco com o azul da marca, o mesmo par do seletor
                      // Voos | Hotéis: no tema escuro o contorno azul sumia.
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand.onSurface,
                          foregroundColor: brand.surface,
                          side: BorderSide(color: brand.surface),
                          minimumSize: const Size.fromHeight(
                            DbookSizes.controlHeight,
                          ),
                        ),
                        onPressed: onFlights,
                        child: const Text('Ver voos'),
                      ),
                    ),
                    const SizedBox(width: DbookSpacing.sm),
                    Expanded(
                      child: DbookButton(
                        label: 'Ver hotel',
                        onPressed: onHotel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
