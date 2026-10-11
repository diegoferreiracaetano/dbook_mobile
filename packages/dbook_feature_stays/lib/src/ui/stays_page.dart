import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/stay_providers.dart';
import 'stay_detail_page.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');
final _dayFormat = DateFormat('dd/MM');

/// Um hotel reservado, pronto para o pagamento. O app (`main.dart`) leva isso
/// para a revisão e pagamento do voo; esta feature não conhece a de reserva.
typedef StayCheckout = ({int bookingId, String label, double price});

/// Quem escolhe o destino: o app injeta o mesmo seletor de aeroporto do voo
/// (features não importam features), então a lista vem do servidor.
typedef DestinationPicker = Future<Destination?> Function(
  BuildContext context,
  List<Destination> destinations,
);

/// Formulário da busca de hotel, no mesmo cartão da busca de voo
/// ([DbookTripSummaryCard]): destino (do mesmo seletor do voo), entrada e
/// saída, hóspedes. Ao buscar, grava em [staySearchProvider]; a lista vem de
/// [StaySearchResults].
class StaySearchCard extends ConsumerStatefulWidget {
  const StaySearchCard({
    super.key,
    required this.destinations,
    required this.pickDestination,
  });

  final List<Destination> destinations;
  final DestinationPicker pickDestination;

  @override
  ConsumerState<StaySearchCard> createState() => _StaySearchCardState();
}

class _StaySearchCardState extends ConsumerState<StaySearchCard> {
  Destination? _destination;
  DateTimeRange? _range;
  var _guests = 2;
  String? _error;

  Future<void> _pickDestination() async {
    final picked = await widget.pickDestination(context, widget.destinations);
    if (picked != null) setState(() => _destination = picked);
  }

  Future<void> _pickRange() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _pickGuests() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _GuestsSheet(initial: _guests),
    );
    if (picked != null) setState(() => _guests = picked);
  }

  void _submit() {
    final destination = _destination;
    if (destination == null) {
      setState(() => _error = 'Escolha o destino.');
      return;
    }
    final range = _range;
    if (range == null || range.duration.inDays < 1) {
      setState(() => _error = 'Escolha entrada e saída em dias diferentes.');
      return;
    }
    setState(() => _error = null);
    ref
        .read(staySearchProvider.notifier)
        .search(
          StaySearch(
            destination: destination.iataCode,
            checkIn: range.start,
            checkOut: range.end,
            guests: _guests,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DbookTripSummaryCard(
          showOrigin: false,
          origin: '',
          destination: _destination?.label ?? 'Selecionar',
          destinationLabel: 'Destino',
          destinationIcon: Icons.place_outlined,
          dateRangeLabel: range == null
              ? 'Escolher'
              : _dayFormat.format(range.start),
          returnDateLabel: range == null
              ? 'Escolher'
              : _dayFormat.format(range.end),
          startDateLabel: 'Entrada',
          endDateLabel: 'Saída',
          passengersFieldLabel: 'Hóspedes',
          passengersLabel: _guests == 1 ? '1 hóspede' : '$_guests hóspedes',
          onTapDestination: _pickDestination,
          onTapDates: _pickRange,
          onTapReturnDate: _pickRange,
          onTapPassengers: _pickGuests,
          searchLabel: 'Buscar hotéis',
          onSearch: _submit,
        ),
        if (_error != null) ...[
          const SizedBox(height: DbookSpacing.sm),
          DbookFieldError(_error!),
        ],
      ],
    );
  }
}

class _GuestsSheet extends StatefulWidget {
  const _GuestsSheet({required this.initial});

  final int initial;

  @override
  State<_GuestsSheet> createState() => _GuestsSheetState();
}

class _GuestsSheetState extends State<_GuestsSheet> {
  late var _guests = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Hóspedes', style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Menos um hóspede',
                  onPressed: _guests > 1
                      ? () => setState(() => _guests--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_guests', style: theme.textTheme.titleMedium),
                IconButton(
                  tooltip: 'Mais um hóspede',
                  onPressed: _guests < 10
                      ? () => setState(() => _guests++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: DbookSpacing.md),
            DbookButton(
              label: 'Confirmar',
              onPressed: () => Navigator.of(context).pop(_guests),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resultados da busca de hotel feita em [StaySearchCard]; vazio até haver
/// uma busca.
class StaySearchResults extends ConsumerWidget {
  const StaySearchResults({
    super.key,
    required this.isLoggedIn,
    required this.onRequireLogin,
    required this.onCheckout,
  });

  final bool isLoggedIn;
  final VoidCallback onRequireLogin;
  final void Function(StayCheckout checkout) onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(staySearchProvider);
    if (search == null) return const SizedBox.shrink();
    return _Results(
      search: search,
      isLoggedIn: isLoggedIn,
      onRequireLogin: onRequireLogin,
      onCheckout: onCheckout,
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.search,
    required this.isLoggedIn,
    required this.onRequireLogin,
    required this.onCheckout,
  });

  final StaySearch search;
  final bool isLoggedIn;
  final VoidCallback onRequireLogin;
  final void Function(StayCheckout checkout) onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(stayResultsProvider(search));
    return results.when(
      loading: () => const SizedBox(
        height: DbookSizes.loadingMd,
        child: DbookLoadingIndicator(),
      ),
      error: (error, _) => DbookErrorState(
        message: stayErrorMessage(error),
        onRetry: () => ref.invalidate(stayResultsProvider(search)),
      ),
      data: (hotels) {
        if (hotels.isEmpty) {
          return const DbookEmptyState(
            icon: Icons.hotel_outlined,
            title: 'Nenhum hotel disponível',
            message: 'Tente outras datas ou outro destino.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final hotel in hotels) ...[
              _HotelCard(
                hotel: hotel,
                nights: search.nights,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StayDetailPage(
                      hotelId: hotel.id,
                      search: search,
                      isLoggedIn: isLoggedIn,
                      onRequireLogin: onRequireLogin,
                      onCheckout: onCheckout,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DbookSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.nights,
    required this.onTap,
  });

  final AccommodationResult hotel;
  final int nights;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = hotel.fromPrice;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
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
                  Text(hotel.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: DbookSpacing.xs),
                  Text(
                    '${'★' * hotel.stars}  ${hotel.city}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (hotel.averageRating != null) ...[
                    const SizedBox(height: DbookSpacing.xs),
                    Text(
                      'Nota ${hotel.averageRating!.toStringAsFixed(1)} '
                      '(${hotel.reviewCount} avaliações)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (from != null) ...[
                    const SizedBox(height: DbookSpacing.md),
                    DbookPriceDisplay(
                      amount: _priceFormat.format(from),
                      caption: 'a partir de, por $nights noites',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
