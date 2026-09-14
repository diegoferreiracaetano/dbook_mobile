import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given flight data when built then airline, times and price render',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              airlineName: 'Iberia',
              flightNumber: 'IB 6821',
              departureTime: '10:30',
              departureAirport: 'GRU',
              arrivalTime: '06:45',
              arrivalAirport: 'MAD',
              durationLabel: '2h 15m',
              price: '\$450',
            ),
          ),
        ),
      );

      expect(find.text('Iberia · IB 6821'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('06:45'), findsOneWidget);
      expect(find.text('Nonstop'), findsOneWidget);
      expect(find.text('\$450'), findsOneWidget);
    },
  );

  testWidgets(
    'given selected true when built then the card border uses the primary color',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              airlineName: 'Iberia',
              departureTime: '10:30',
              departureAirport: 'GRU',
              arrivalTime: '06:45',
              arrivalAirport: 'MAD',
              durationLabel: '2h 15m',
              price: '\$450',
              selected: true,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.color, DbookColorScheme.light.primary);
    },
  );

  testWidgets(
    'given an airlineIataCode and airlineColor when built then the badge '
    'shows the code instead of the generic icon',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              airlineName: 'Iberia',
              airlineIataCode: 'IB',
              airlineColor: Colors.red,
              departureTime: '10:30',
              departureAirport: 'GRU',
              arrivalTime: '06:45',
              arrivalAirport: 'MAD',
              durationLabel: '2h 15m',
              price: '\$450',
            ),
          ),
        ),
      );

      expect(find.text('IB'), findsOneWidget);
    },
  );

  testWidgets(
    'given an aircraftType when built then it renders as an extra line',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookFlightResultTile(
              airlineName: 'Iberia',
              departureTime: '10:30',
              departureAirport: 'GRU',
              arrivalTime: '06:45',
              arrivalAirport: 'MAD',
              durationLabel: '2h 15m',
              price: '\$450',
              aircraftType: 'Boeing 777',
            ),
          ),
        ),
      );

      expect(find.text('Boeing 777'), findsOneWidget);
    },
  );

  testWidgets('given no aircraftType when built then no extra line renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookFlightResultTile(
            airlineName: 'Iberia',
            departureTime: '10:30',
            departureAirport: 'GRU',
            arrivalTime: '06:45',
            arrivalAirport: 'MAD',
            durationLabel: '2h 15m',
            price: '\$450',
          ),
        ),
      ),
    );

    expect(find.text('Boeing 777'), findsNothing);
  });
}
