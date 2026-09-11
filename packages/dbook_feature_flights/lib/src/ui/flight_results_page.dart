import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/flight_providers.dart';
import '../state/flight_search_state.dart';
import 'flight_search_page.dart';

final _dateFormat = DateFormat('EEE, MMM d');
final _timeFormat = DateFormat('HH:mm');
final _priceFormat = NumberFormat.currency(symbol: r'$');

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

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

/// Resultados da busca — dispara `FlightSearchNotifier.search` assim que
/// monta (a tela recebe a query já preenchida da busca) e reage ao estado
/// idle/loading/success/error.
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
          date: widget.query.date,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightSearchNotifierProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Flight Results'),
      body: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DbookTripSummaryCard(
              compact: true,
              origin: widget.query.origin.label,
              destination: widget.query.destination.label,
              dateRangeLabel: _dateFormat.format(widget.query.date),
              passengersLabel: '1 Passenger',
            ),
            const SizedBox(height: DbookSpacing.lg),
            Expanded(
              child: _ResultsBody(
                state: state,
                onRetry: _search,
                onSelectFlight: widget.onSelectFlight,
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
    required this.onRetry,
    required this.onSelectFlight,
  });

  final FlightSearchState state;
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
      FlightSearchSuccess(:final flights) => _FlightList(
        flights: flights,
        onSelectFlight: onSelectFlight,
      ),
    };
  }
}

class _FlightList extends StatelessWidget {
  const _FlightList({required this.flights, required this.onSelectFlight});

  final List<Flight> flights;
  final ValueChanged<Flight> onSelectFlight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: flights.length,
      separatorBuilder: (_, _) => const SizedBox(height: DbookSpacing.sm),
      itemBuilder: (context, index) {
        final flight = flights[index];
        return DbookFlightResultTile(
          airlineName: 'DBook Airlines',
          flightNumber: flight.flightNumber,
          departureTime: _timeFormat.format(flight.departureTime),
          departureAirport: flight.originIataCode,
          arrivalTime: _timeFormat.format(flight.arrivalTime),
          arrivalAirport: flight.destinationIataCode,
          durationLabel: _formatDuration(
            flight.arrivalTime.difference(flight.departureTime),
          ),
          stopsLabel: _seatClassLabel(flight.seatClass),
          price: _priceFormat.format(flight.price),
          onTap: () => onSelectFlight(flight),
        );
      },
    );
  }
}
