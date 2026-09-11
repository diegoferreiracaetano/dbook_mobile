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
/// backend não expõe). A ação de reservar chega no M5.
class FlightDetailPage extends StatelessWidget {
  const FlightDetailPage({super.key, required this.flight});

  final Flight flight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DbookAppBar(title: 'Flight Details'),
      body: Padding(
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
                    DbookSummaryRow(
                      label: 'Seats available',
                      value: '${flight.availableCapacity}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DbookSpacing.lg),
            DbookPriceDisplay(
              amount: _priceFormat.format(flight.price),
              caption: 'per passenger',
            ),
          ],
        ),
      ),
    );
  }
}
