import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/stay_providers.dart';
import 'stays_page.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');
final _dayFormat = DateFormat('dd/MM/yyyy');

/// Detalhe do hotel com os quartos **da estadia buscada**: só aparecem os que
/// têm vaga em todas as noites, com o total que o servidor calculou. Reservar
/// cria a reserva pendente (15 min) e entrega ao app para o pagamento.
class StayDetailPage extends ConsumerStatefulWidget {
  const StayDetailPage({
    super.key,
    required this.hotelId,
    required this.search,
    required this.isLoggedIn,
    required this.onRequireLogin,
    required this.onCheckout,
  });

  final int hotelId;
  final StaySearch search;
  final bool isLoggedIn;
  final VoidCallback onRequireLogin;
  final void Function(StayCheckout checkout) onCheckout;

  @override
  ConsumerState<StayDetailPage> createState() => _StayDetailPageState();
}

/// Ícone e rótulo em português de cada comodidade conhecida; as que o
/// servidor mandar e não estiverem aqui aparecem com o código e um ícone
/// genérico (nada some).
const _amenities = <String, (IconData, String)>{
  'wifi': (Icons.wifi, 'Wi-Fi'),
  'breakfast': (Icons.free_breakfast_outlined, 'Café da manhã'),
  'pool': (Icons.pool_outlined, 'Piscina'),
  'spa': (Icons.spa_outlined, 'Spa'),
  'gym': (Icons.fitness_center_outlined, 'Academia'),
  'parking': (Icons.local_parking_outlined, 'Estacionamento'),
  'air_conditioning': (Icons.ac_unit, 'Ar-condicionado'),
  'restaurant': (Icons.restaurant_outlined, 'Restaurante'),
  'bar': (Icons.local_bar_outlined, 'Bar'),
  'pets': (Icons.pets_outlined, 'Aceita pets'),
};

class _StayDetailPageState extends ConsumerState<StayDetailPage> {
  int? _booking;
  String? _error;
  final _roomsKey = GlobalKey();

  Future<void> _book(AccommodationDetail hotel, RoomOffer room) async {
    if (!widget.isLoggedIn) {
      widget.onRequireLogin();
      return;
    }
    setState(() {
      _booking = room.roomTypeId;
      _error = null;
    });
    try {
      final id = await ref
          .read(accommodationRepositoryProvider)
          .book(
            accommodationId: hotel.id,
            roomTypeId: room.roomTypeId,
            checkIn: widget.search.checkIn,
            checkOut: widget.search.checkOut,
            guests: widget.search.guests,
          );
      if (!mounted) return;
      // a página volta a ficar usável: o app empilha o pagamento por cima, e
      // quem volta dele não pode encontrar o botão preso em "carregando"
      setState(() => _booking = null);
      widget.onCheckout((
        bookingId: id,
        label: '${hotel.name} · ${room.name} · ${widget.search.nights} noites',
        price: room.totalPrice,
      ));
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      // Uma noite pode ter enchido desde a busca (409): refaz a lista.
      ref.invalidate(stayResultsProvider(widget.search));
      setState(() {
        _booking = null;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(stayDetailProvider(widget.hotelId));
    final results = ref.watch(stayResultsProvider(widget.search));

    return Scaffold(
      appBar: const DbookAppBar(title: 'Hotel'),
      body: detail.when(
        loading: () => const DbookLoadingIndicator(),
        error: (error, _) => DbookErrorState(
          message: stayErrorMessage(error),
          onRetry: () => ref.invalidate(stayDetailProvider(widget.hotelId)),
        ),
        data: (hotel) {
          final rooms =
              results.value
                  ?.where((r) => r.id == hotel.id)
                  .expand((r) => r.rooms)
                  .toList() ??
              const <RoomOffer>[];
          final cheapest = rooms.isEmpty
              ? null
              : rooms.map((r) => r.totalPrice).reduce((a, b) => a < b ? a : b);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 200,
                      child: DbookPhoto(
                        url: hotel.photoUrl,
                        icon: Icons.hotel_outlined,
                        semanticLabel: 'Foto do ${hotel.name}',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DbookSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._header(hotel),
                          ..._roomList(context, hotel, rooms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (cheapest != null)
                _PriceBar(
                  price: _priceFormat.format(cheapest),
                  onTap: () => Scrollable.ensureVisible(
                    _roomsKey.currentContext!,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _header(AccommodationDetail hotel) {
    final theme = Theme.of(context);
    return [
      Text(hotel.name, style: theme.textTheme.headlineSmall),
      const SizedBox(height: DbookSpacing.xs),
      Text(
        '${'★' * hotel.stars}  ${hotel.address}, ${hotel.city}',
        style: theme.textTheme.bodyMedium,
      ),
      if (hotel.description != null) ...[
        const SizedBox(height: DbookSpacing.md),
        Text(hotel.description!, style: theme.textTheme.bodyMedium),
      ],
      if (hotel.amenities.isNotEmpty) ...[
        const SizedBox(height: DbookSpacing.lg),
        Text('Comodidades', style: theme.textTheme.titleSmall),
        const SizedBox(height: DbookSpacing.sm),
        Wrap(
          spacing: DbookSpacing.lg,
          runSpacing: DbookSpacing.md,
          children: [
            for (final amenity in hotel.amenities)
              _AmenityItem(
                icon: _amenities[amenity]?.$1 ?? Icons.check_circle_outline,
                label: _amenities[amenity]?.$2 ?? amenity,
              ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _roomList(
    BuildContext context,
    AccommodationDetail hotel,
    List<RoomOffer> rooms,
  ) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: DbookSpacing.xl),
      Text('Quartos', key: _roomsKey, style: theme.textTheme.titleMedium),
      const SizedBox(height: DbookSpacing.xs),
      Text(
        '${_dayFormat.format(widget.search.checkIn)} a '
        '${_dayFormat.format(widget.search.checkOut)} · '
        '${widget.search.nights} noites · '
        '${widget.search.guests} hóspedes',
        style: theme.textTheme.titleSmall,
      ),
      if (_error != null) DbookFieldError(_error!),
      const SizedBox(height: DbookSpacing.md),
      if (rooms.isEmpty)
        const DbookEmptyState(
          icon: Icons.bed_outlined,
          title: 'Sem quarto livre',
          message: 'Nenhum quarto cobre todas as noites escolhidas.',
        ),
      for (final room in rooms) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name, style: theme.textTheme.titleMedium),
                Text(
                  'Até ${room.capacity} hóspedes · '
                  '${_priceFormat.format(room.nightlyRate)} por noite',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: DbookSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DbookPriceDisplay(
                        amount: _priceFormat.format(room.totalPrice),
                        caption: 'total da estadia',
                      ),
                    ),
                    DbookButton(
                      label: 'Reservar',
                      isLoading: _booking == room.roomTypeId,
                      onPressed: _booking == null
                          ? () => _book(hotel, room)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DbookSpacing.md),
      ],
    ];
  }
}

class _AmenityItem extends StatelessWidget {
  const _AmenityItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: DbookSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Barra fixa embaixo: o menor total entre os quartos livres e a ação de ir
/// para a lista, como na referência (preço à esquerda, CTA à direita).
class _PriceBar extends StatelessWidget {
  const _PriceBar({required this.price, required this.onTap});

  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: DbookPriceDisplay(
                  amount: price,
                  caption: 'a partir de, total da estadia',
                ),
              ),
              DbookButton(label: 'Selecionar quarto', onPressed: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
