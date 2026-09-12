import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateTimeFormat = DateFormat('EEE, MMM d, yyyy · HH:mm');
final _priceFormat = NumberFormat.currency(symbol: r'$');

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
                          '${flight.originIataCode} → ${flight.destinationIataCode}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Chip(label: Text(_seatClassLabel(flight.seatClass))),
                      ],
                    ),
                    const SizedBox(height: DbookSpacing.md),
                    DbookSummaryRow(
                      label: 'Flight number',
                      value: flight.flightNumber,
                    ),
                    DbookSummaryRow(
                      label: 'Departure',
                      value: _dateTimeFormat.format(flight.departureTime),
                    ),
                    DbookSummaryRow(
                      label: 'Arrival',
                      value: _dateTimeFormat.format(flight.arrivalTime),
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
