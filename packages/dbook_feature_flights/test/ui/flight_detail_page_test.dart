import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a flight when built then shows every field', (
    tester,
  ) async {
    final flight = Flight(
      id: 1,
      flightNumber: 'IB 6821',
      airlineIataCode: 'IB',
      airlineName: 'Iberia',
      originIataCode: 'GRU',
      destinationIataCode: 'MAD',
      departureTime: DateTime(2026, 1, 13, 10, 30),
      arrivalTime: DateTime(2026, 1, 14, 6, 45),
      seatClass: SeatClass.business,
      price: 1250,
      availableCapacity: 4,
      aircraftType: 'Airbus A320',
      seatLayout: const [3, 3],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: FlightDetailPage(flight: flight),
      ),
    );

    expect(find.text('GRU'), findsOneWidget);
    expect(find.text('MAD'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    expect(find.text('06:45'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('IB 6821'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text(r'$1,250.00'), findsOneWidget);
    expect(find.text('Book This Flight'), findsNothing);
  });

  testWidgets(
    'given onBook when Book This Flight is tapped then reports the flight',
    (tester) async {
      Flight? booked;
      final flight = Flight(
        id: 1,
        flightNumber: 'IB 6821',
        airlineIataCode: 'IB',
        airlineName: 'Iberia',
        originIataCode: 'GRU',
        destinationIataCode: 'MAD',
        departureTime: DateTime(2026, 1, 13, 10, 30),
        arrivalTime: DateTime(2026, 1, 14, 6, 45),
        seatClass: SeatClass.business,
        price: 1250,
        availableCapacity: 4,
        aircraftType: 'Airbus A320',
        seatLayout: const [3, 3],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: FlightDetailPage(
            flight: flight,
            onBook: (value) => booked = value,
          ),
        ),
      );

      await tester.tap(find.text('Book This Flight'));

      expect(booked, flight);
    },
  );

  testWidgets(
    'given liveAvailability when built then shows it instead of the static '
    'capacity',
    (tester) async {
      final flight = Flight(
        id: 1,
        flightNumber: 'IB 6821',
        airlineIataCode: 'IB',
        airlineName: 'Iberia',
        originIataCode: 'GRU',
        destinationIataCode: 'MAD',
        departureTime: DateTime(2026, 1, 13, 10, 30),
        arrivalTime: DateTime(2026, 1, 14, 6, 45),
        seatClass: SeatClass.business,
        price: 1250,
        availableCapacity: 4,
        aircraftType: 'Airbus A320',
        seatLayout: const [3, 3],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: FlightDetailPage(
            flight: flight,
            liveAvailability: const Text('live-availability-widget'),
          ),
        ),
      );

      expect(find.text('Seats available'), findsOneWidget);
      expect(find.text('live-availability-widget'), findsOneWidget);
      expect(find.text('4'), findsNothing);
    },
  );
}
