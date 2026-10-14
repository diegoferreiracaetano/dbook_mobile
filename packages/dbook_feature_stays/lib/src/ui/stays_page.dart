import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/recent_stay_searches.dart';
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
  var _recent = const <RecentStaySearch>[];

  @override
  void initState() {
    super.initState();
    RecentStaySearches.load().then((list) {
      if (mounted) setState(() => _recent = list);
    });
  }

  void _useRecent(RecentStaySearch recent) {
    final match = widget.destinations.where(
      (d) => d.iataCode == recent.destinationCode,
    );
    if (match.isEmpty) return;
    setState(() {
      _destination = match.first;
      _range = DateTimeRange(start: recent.checkIn, end: recent.checkOut);
      _guests = recent.guests;
      _error = null;
    });
  }

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
    final search = StaySearch(
      destination: destination.iataCode,
      checkIn: range.start,
      checkOut: range.end,
      guests: _guests,
    );
    ref.read(staySearchProvider.notifier).search(search);
    RecentStaySearches.add(destination, search).then((list) {
      if (mounted) setState(() => _recent = list);
    });
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
        if (_recent.isNotEmpty) ...[
          const SizedBox(height: DbookSpacing.md),
          // sobre a faixa de marca: o texto leva a cor própria dela
          Text(
            'Buscas recentes',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).extension<DbookBrandColors>()?.onSurface,
            ),
          ),
          const SizedBox(height: DbookSpacing.sm),
          Wrap(
            spacing: DbookSpacing.sm,
            runSpacing: DbookSpacing.sm,
            children: [
              for (final recent in _recent)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(
                    '${recent.destinationLabel} · '
                    '${_dayFormat.format(recent.checkIn)}–'
                    '${_dayFormat.format(recent.checkOut)}',
                  ),
                  onPressed: () => _useRecent(recent),
                ),
            ],
          ),
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

class _Results extends ConsumerStatefulWidget {
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
  ConsumerState<_Results> createState() => _ResultsState();
}

class _ResultsState extends ConsumerState<_Results> {
  // Filtros do que já foi carregado: o servidor devolveu a busca inteira, e
  // estrelas e ordem são só recortes e ordenação da lista na tela.
  static const _starFilters = [0, 3, 4, 5];
  var _starsIndex = 0;
  var _cheapestFirst = false;
  RangeValues? _priceRange;

  Future<void> _openFilters(double low, double high) async {
    final result = await showModalBottomSheet<_HotelFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FiltersSheet(
        low: low,
        high: high,
        initial: _HotelFilters(
          starsIndex: _starsIndex,
          priceRange: _priceRange ?? RangeValues(low, high),
          cheapestFirst: _cheapestFirst,
        ),
        stars: _starFilters,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _starsIndex = result.starsIndex;
      _cheapestFirst = result.cheapestFirst;
      final full =
          result.priceRange.start <= low && result.priceRange.end >= high;
      _priceRange = full ? null : result.priceRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    final search = widget.search;
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
      data: (all) {
        if (all.isEmpty) {
          return const DbookEmptyState(
            icon: Icons.hotel_outlined,
            title: 'Nenhum hotel disponível',
            message: 'Tente outras datas ou outro destino.',
          );
        }
        final minStars = _starFilters[_starsIndex];
        final prices = [
          for (final h in all)
            if (h.fromPrice != null) h.fromPrice!,
        ];
        final low = prices.isEmpty ? 0.0 : prices.reduce(math.min);
        final high = prices.isEmpty ? 0.0 : prices.reduce(math.max);
        final range = _priceRange;
        final hotels = all
            .where((h) => h.stars >= minStars)
            .where(
              (h) =>
                  range == null ||
                  h.fromPrice == null ||
                  (h.fromPrice! >= range.start && h.fromPrice! <= range.end),
            )
            .toList();
        if (_cheapestFirst) {
          hotels.sort(
            (a, b) => (a.fromPrice ?? double.infinity).compareTo(
              b.fromPrice ?? double.infinity,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DbookChipRow(
              labels: const ['Todas', '3★ ou mais', '4★ ou mais', '5★'],
              selectedIndex: _starsIndex,
              onSelected: (i) => setState(() => _starsIndex = i),
            ),
            const SizedBox(height: DbookSpacing.sm),
            Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.tune, size: 18),
                  label: Text(
                    _priceRange == null ? 'Filtros' : 'Filtros (preço)',
                  ),
                  onPressed: high > low ? () => _openFilters(low, high) : null,
                ),
                const SizedBox(width: DbookSpacing.sm),
                FilterChip(
                  label: const Text('Menor preço primeiro'),
                  selected: _cheapestFirst,
                  onSelected: (v) => setState(() => _cheapestFirst = v),
                ),
              ],
            ),
            const SizedBox(height: DbookSpacing.md),
            if (hotels.isEmpty)
              const DbookEmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'Nenhum hotel com esse filtro',
                message:
                    'Afrouxe as estrelas ou a faixa de preço para ver mais.',
              ),
            for (final hotel in hotels) ...[
              _HotelCard(
                hotel: hotel,
                nights: search.nights,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StayDetailPage(
                      hotelId: hotel.id,
                      search: search,
                      isLoggedIn: widget.isLoggedIn,
                      onRequireLogin: widget.onRequireLogin,
                      onCheckout: widget.onCheckout,
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
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: DbookSpacing.xs),
                      Expanded(
                        child: Text(
                          '${hotel.address}, ${hotel.city} · '
                          '${'★' * hotel.stars}',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _HotelFilters {
  const _HotelFilters({
    required this.starsIndex,
    required this.priceRange,
    required this.cheapestFirst,
  });

  final int starsIndex;
  final RangeValues priceRange;
  final bool cheapestFirst;
}

/// Folha "Filtros": estrelas, faixa de preço do total da estadia e ordem.
/// Opera sobre o que a busca já trouxe; nada vai ao servidor.
class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.low,
    required this.high,
    required this.initial,
    required this.stars,
  });

  final double low;
  final double high;
  final _HotelFilters initial;
  final List<int> stars;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late var _stars = widget.initial.starsIndex;
  late var _range = widget.initial.priceRange;
  late var _cheapest = widget.initial.cheapestFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label(int i) => i == 0 ? 'Todas' : '${widget.stars[i]}★ ou mais';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtros', style: theme.textTheme.titleLarge),
            const SizedBox(height: DbookSpacing.lg),
            const DbookSectionLabel(text: 'Estrelas'),
            const SizedBox(height: DbookSpacing.sm),
            Wrap(
              spacing: DbookSpacing.sm,
              children: [
                for (var i = 0; i < widget.stars.length; i++)
                  ChoiceChip(
                    label: Text(label(i)),
                    selected: _stars == i,
                    onSelected: (_) => setState(() => _stars = i),
                  ),
              ],
            ),
            const SizedBox(height: DbookSpacing.lg),
            const DbookSectionLabel(text: 'Faixa de preço (a partir de)'),
            RangeSlider(
              min: widget.low,
              max: widget.high,
              values: _range,
              labels: RangeLabels(
                _priceFormat.format(_range.start),
                _priceFormat.format(_range.end),
              ),
              onChanged: (v) => setState(() => _range = v),
            ),
            Row(
              children: [
                Text(_priceFormat.format(_range.start)),
                const Spacer(),
                Text(_priceFormat.format(_range.end)),
              ],
            ),
            const SizedBox(height: DbookSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Menor preço primeiro'),
              value: _cheapest,
              onChanged: (v) => setState(() => _cheapest = v),
            ),
            const SizedBox(height: DbookSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DbookButton(
                    label: 'Redefinir',
                    variant: DbookButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(
                      _HotelFilters(
                        starsIndex: 0,
                        priceRange: RangeValues(widget.low, widget.high),
                        cheapestFirst: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DbookSpacing.md),
                Expanded(
                  child: DbookButton(
                    label: 'Aplicar',
                    onPressed: () => Navigator.of(context).pop(
                      _HotelFilters(
                        starsIndex: _stars,
                        priceRange: _range,
                        cheapestFirst: _cheapest,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
