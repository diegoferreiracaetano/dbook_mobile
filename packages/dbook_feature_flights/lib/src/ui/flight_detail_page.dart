import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _timeFormat = DateFormat('HH:mm');
final _dateFormat = DateFormat('EEE, MMM d');
final _priceFormat = NumberFormat.currency(symbol: r'$');

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}m';
}

String _seatClassLabel(SeatClass seatClass) => switch (seatClass) {
  SeatClass.economy => 'Economy',
  SeatClass.premiumEconomy => 'Premium Economy',
  SeatClass.business => 'Business',
  SeatClass.first => 'First',
};

/// Detalhe de um voo já buscado — recebe o [Flight] escolhido na lista de
/// resultados (evita rebuscar ou modelar um "GET /flights/{id}" que o
/// backend não expõe). [onBook] mora na feature de reserva (M5) e
/// [liveAvailability] na de tempo real (M6) — a de voos não importa
/// nenhuma das duas (features não importam features), então quem monta
/// essa tela decide o que cada uma faz.
class FlightDetailPage extends StatelessWidget {
  const FlightDetailPage({
    super.key,
    required this.flight,
    this.onBook,
    this.liveAvailability,
  });

  final Flight flight;
  final ValueChanged<Flight>? onBook;
  final Widget? liveAvailability;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DbookAppBar(title: 'Flight Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DbookSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateFormat.format(flight.departureTime),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Chip(label: Text(_seatClassLabel(flight.seatClass))),
                      ],
                    ),
                    const SizedBox(height: DbookSpacing.lg),
                    _FlightRouteTimeline(flight: flight),
                    const SizedBox(height: DbookSpacing.lg),
                    DbookSummaryRow(
                      label: 'Flight number',
                      value: flight.flightNumber,
                    ),
                    if (liveAvailability != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: DbookSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seats available',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            liveAvailability!,
                          ],
                        ),
                      )
                    else
                      DbookSummaryRow(
                        label: 'Seats available',
                        value: '${flight.availableCapacity}',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // M9-9.2: preço + ação primária sempre visíveis, fixos no rodapé —
      // mesmo arranjo da tela de referência (kit, 06).
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(DbookSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: DbookPriceDisplay(
                amount: _priceFormat.format(flight.price),
                caption: 'per passenger',
              ),
            ),
            if (onBook != null) ...[
              const SizedBox(width: DbookSpacing.md),
              DbookButton(
                label: 'Book This Flight',
                onPressed: () => onBook!(flight),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rota do voo com horários grandes e a mesma linha pontilhada + ícone de
/// avião do card de resultado (`DbookFlightResultTile`) — reaproveita a
/// mesma composição visual em vez de inventar outra.
class _FlightRouteTimeline extends StatelessWidget {
  const _FlightRouteTimeline({required this.flight});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _timeFormat.format(flight.departureTime),
              style: textTheme.headlineSmall,
            ),
            Text(flight.originIataCode, style: subtitleStyle),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatDuration(
                  flight.arrivalTime.difference(flight.departureTime),
                ),
                style: subtitleStyle,
              ),
              const SizedBox(height: DbookSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: colorScheme.outlineVariant, height: 1),
                  ),
                  Icon(Icons.flight, size: 16, color: colorScheme.primary),
                  Expanded(
                    child: Divider(color: colorScheme.outlineVariant, height: 1),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _timeFormat.format(flight.arrivalTime),
              style: textTheme.headlineSmall,
            ),
            Text(flight.destinationIataCode, style: subtitleStyle),
          ],
        ),
      ],
    );
  }
}
