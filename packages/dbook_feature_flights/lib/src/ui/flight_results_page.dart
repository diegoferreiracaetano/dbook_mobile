import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../airline_colors.dart';
import '../state/date_strip_provider.dart';
import '../state/flight_providers.dart';
import '../state/flight_search_state.dart';
import 'flight_search_page.dart';

final _dateFormatFull = DateFormat('EEE, MMM d');
final _dateChipFormat = DateFormat('EEE d');
final _timeFormat = DateFormat('HH:mm');
final _priceFormat = NumberFormat.currency(symbol: r'$');
final _priceFormatWhole = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Assentos não têm classe cadastrada como "paradas" no backend (voos são
/// sempre diretos aqui) — reaproveita o slot de `stopsLabel` do
/// `DbookFlightResultTile` pra mostrar a classe da cabine, informação bem
/// mais útil já que o mesmo voo pode aparecer mais de uma vez por classe.
String _seatClassLabel(SeatClass seatClass) => switch (seatClass) {
  SeatClass.economy => 'Economy',
  SeatClass.premiumEconomy => 'Premium Economy',
  SeatClass.business => 'Business',
  SeatClass.first => 'First',
};

enum _SortOrder {
  priceAsc('Price (low to high)'),
  durationAsc('Duration (shortest first)');

  const _SortOrder(this.label);

  final String label;
}

class _FilterResult {
  const _FilterResult({required this.sortOrder, required this.classFilter});

  final _SortOrder sortOrder;
  final SeatClass? classFilter;
}

/// Resultados da busca — dispara `FlightSearchNotifier.search` assim que
/// monta ou quando a data selecionada na faixa muda, e reage ao estado
/// idle/loading/success/error. A faixa de datas (`dateStripProvider`) busca
/// o menor preço real de ±2 dias em paralelo à busca principal.
class FlightResultsPage extends ConsumerStatefulWidget {
  const FlightResultsPage({
    super.key,
    required this.query,
    required this.onSelectFlight,
  });

  final FlightSearchQuery query;
  final ValueChanged<Flight> onSelectFlight;

  @override
  ConsumerState<FlightResultsPage> createState() => _FlightResultsPageState();
}

class _FlightResultsPageState extends ConsumerState<FlightResultsPage> {
  late DateTime _selectedDate = widget.query.date;
  _SortOrder _sortOrder = _SortOrder.priceAsc;
  SeatClass? _classFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  void _search() {
    ref
        .read(flightSearchNotifierProvider.notifier)
        .search(
          originIataCode: widget.query.origin.iataCode,
          destinationIataCode: widget.query.destination.iataCode,
          date: _selectedDate,
        );
  }

  void _selectDate(DateTime date) {
    if (_isSameDay(date, _selectedDate)) return;
    setState(() => _selectedDate = date);
    _search();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FilterSheet(
        initialSort: _sortOrder,
        initialClassFilter: _classFilter,
      ),
    );
    if (result == null) return;
    setState(() {
      _sortOrder = result.sortOrder;
      _classFilter = result.classFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightSearchNotifierProvider);
    final dateOptions = ref.watch(
      dateStripProvider(
        DateStripQuery(
          originIataCode: widget.query.origin.iataCode,
          destinationIataCode: widget.query.destination.iataCode,
          centerDate: _selectedDate,
        ),
      ),
    );

    return Scaffold(
      appBar: DbookAppBar(
        title: '${widget.query.origin.city} → ${widget.query.destination.city}',
        subtitle: '${_dateFormatFull.format(_selectedDate)} · 1 Passenger',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DbookSpacing.md),
            child: OutlinedButton.icon(
              onPressed: _openFilterSheet,
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: const Text('Filter'),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateStrip(
            options: dateOptions,
            selectedDate: _selectedDate,
            onSelect: _selectDate,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DbookSpacing.lg,
                0,
                DbookSpacing.lg,
                DbookSpacing.lg,
              ),
              child: _ResultsBody(
                state: state,
                dateOptions: dateOptions.value,
                selectedDate: _selectedDate,
                sortOrder: _sortOrder,
                classFilter: _classFilter,
                onRetry: _search,
                onSelectFlight: widget.onSelectFlight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.options,
    required this.selectedDate,
    required this.onSelect,
  });

  final AsyncValue<List<DateOption>> options;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final list = options.value;

    if (list == null && options.hasError) {
      // The main results body already shows a retry UI for a failed search —
      // no need to duplicate it here, and showing the spinner forever would
      // never let `pumpAndSettle` (or a real user) settle.
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 76,
      child: list == null
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DbookSpacing.lg,
                vertical: DbookSpacing.sm,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: DbookSpacing.sm),
              itemBuilder: (context, index) {
                final option = list[index];
                return _DateChip(
                  option: option,
                  selected: _isSameDay(option.date, selectedDate),
                  onTap: () => onSelect(option.date),
                );
              },
            ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DateOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background = selected
        ? colorScheme.primary
        : colorScheme.surfaceContainerLow;
    final foreground = selected ? colorScheme.onPrimary : colorScheme.onSurface;
    final subForeground = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DbookRadius.md),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: DbookSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(DbookRadius.md),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dateChipFormat.format(option.date),
              style: textTheme.labelMedium?.copyWith(color: foreground),
            ),
            const SizedBox(height: 2),
            Text(
              option.lowestPrice == null
                  ? '—'
                  : _priceFormatWhole.format(option.lowestPrice),
              style: textTheme.labelSmall?.copyWith(
                color: subForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.state,
    required this.dateOptions,
    required this.selectedDate,
    required this.sortOrder,
    required this.classFilter,
    required this.onRetry,
    required this.onSelectFlight,
  });

  final FlightSearchState state;
  final List<DateOption>? dateOptions;
  final DateTime selectedDate;
  final _SortOrder sortOrder;
  final SeatClass? classFilter;
  final VoidCallback onRetry;
  final ValueChanged<Flight> onSelectFlight;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      FlightSearchIdle() || FlightSearchLoading() =>
        const DbookLoadingIndicator(message: 'Buscando voos...'),
      FlightSearchError(:final message) => DbookStatusPlaceholder(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Não foi possível buscar',
        message: message,
        actionLabel: 'Tentar de novo',
        onAction: onRetry,
      ),
      FlightSearchSuccess(:final flights) when flights.isEmpty =>
        const DbookStatusPlaceholder(
          icon: Icons.flight_outlined,
          title: 'Nenhum voo encontrado',
          message: 'Tente outra data ou outra rota.',
        ),
      FlightSearchSuccess(:final flights) => _FlightResults(
        flights: flights,
        dateOptions: dateOptions,
        selectedDate: selectedDate,
        sortOrder: sortOrder,
        classFilter: classFilter,
        onSelectFlight: onSelectFlight,
      ),
    };
  }
}

class _FlightResults extends StatelessWidget {
  const _FlightResults({
    required this.flights,
    required this.dateOptions,
    required this.selectedDate,
    required this.sortOrder,
    required this.classFilter,
    required this.onSelectFlight,
  });

  final List<Flight> flights;
  final List<DateOption>? dateOptions;
  final DateTime selectedDate;
  final _SortOrder sortOrder;
  final SeatClass? classFilter;
  final ValueChanged<Flight> onSelectFlight;

  bool get _isBestPriceDay {
    final options = dateOptions;
    if (options == null) return false;

    DateOption? selected;
    for (final option in options) {
      if (_isSameDay(option.date, selectedDate)) {
        selected = option;
        break;
      }
    }
    if (selected?.lowestPrice == null) return false;

    final prices = [
      for (final option in options)
        if (option.lowestPrice != null) option.lowestPrice!,
    ];
    return selected!.lowestPrice == prices.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = classFilter == null
        ? flights
        : flights.where((flight) => flight.seatClass == classFilter).toList();
    final sorted = [...filtered]
      ..sort(switch (sortOrder) {
        _SortOrder.priceAsc => (a, b) => a.price.compareTo(b.price),
        _SortOrder.durationAsc =>
          (a, b) => a.arrivalTime
              .difference(a.departureTime)
              .compareTo(b.arrivalTime.difference(b.departureTime)),
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DbookSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sorted.length} flight${sorted.length == 1 ? '' : 's'} found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (_isBestPriceDay) const _BestPriceBadge(),
            ],
          ),
        ),
        if (sorted.isEmpty)
          const Expanded(
            child: DbookStatusPlaceholder(
              icon: Icons.filter_alt_off_outlined,
              title: 'Nenhum voo com esse filtro',
              message: 'Tente outra classe de cabine.',
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: DbookSpacing.sm),
              itemBuilder: (context, index) {
                final flight = sorted[index];
                return DbookFlightResultTile(
                  airlineName: flight.airlineName,
                  airlineIataCode: flight.airlineIataCode,
                  airlineColor: airlineColorFor(flight.airlineIataCode),
                  flightNumber: flight.flightNumber,
                  departureTime: _timeFormat.format(flight.departureTime),
                  departureAirport: flight.originIataCode,
                  arrivalTime: _timeFormat.format(flight.arrivalTime),
                  arrivalAirport: flight.destinationIataCode,
                  durationLabel: _formatDuration(
                    flight.arrivalTime.difference(flight.departureTime),
                  ),
                  stopsLabel: _seatClassLabel(flight.seatClass),
                  aircraftType: flight.aircraftType,
                  price: _priceFormat.format(flight.price),
                  onTap: () => onSelectFlight(flight),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _BestPriceBadge extends StatelessWidget {
  const _BestPriceBadge();

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<DbookStatusColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: statusColors.successContainer,
        borderRadius: BorderRadius.circular(DbookRadius.full),
      ),
      child: Text(
        'Best prices today',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: statusColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialSort,
    required this.initialClassFilter,
  });

  final _SortOrder initialSort;
  final SeatClass? initialClassFilter;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _SortOrder _sortOrder = widget.initialSort;
  late SeatClass? _classFilter = widget.initialClassFilter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        DbookSpacing.lg,
        DbookSpacing.md,
        DbookSpacing.lg,
        DbookSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: textTheme.titleSmall),
          const SizedBox(height: DbookSpacing.xs),
          RadioGroup<_SortOrder>(
            groupValue: _sortOrder,
            onChanged: (value) => setState(() => _sortOrder = value!),
            child: Column(
              children: [
                for (final order in _SortOrder.values)
                  InkWell(
                    onTap: () => setState(() => _sortOrder = order),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: DbookSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Radio<_SortOrder>(value: order),
                          const SizedBox(width: DbookSpacing.sm),
                          Text(order.label),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DbookSpacing.md),
          Text('Cabin class', style: textTheme.titleSmall),
          const SizedBox(height: DbookSpacing.sm),
          Wrap(
            spacing: DbookSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _classFilter == null,
                onSelected: (_) => setState(() => _classFilter = null),
              ),
              for (final seatClass in SeatClass.values)
                ChoiceChip(
                  label: Text(_seatClassLabel(seatClass)),
                  selected: _classFilter == seatClass,
                  onSelected: (_) => setState(() => _classFilter = seatClass),
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          DbookButton(
            label: 'Apply',
            onPressed: () => Navigator.of(context).pop(
              _FilterResult(sortOrder: _sortOrder, classFilter: _classFilter),
            ),
          ),
        ],
      ),
    );
  }
}
