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

class _StayDetailPageState extends ConsumerState<StayDetailPage> {
  int? _booking;
  String? _error;

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
    final theme = Theme.of(context);

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
          return ListView(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            children: [
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
                const SizedBox(height: DbookSpacing.md),
                Wrap(
                  spacing: DbookSpacing.sm,
                  runSpacing: DbookSpacing.sm,
                  children: [
                    for (final amenity in hotel.amenities)
                      Chip(label: Text(amenity)),
                  ],
                ),
              ],
              const SizedBox(height: DbookSpacing.xl),
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
            ],
          );
        },
      ),
    );
  }
}
