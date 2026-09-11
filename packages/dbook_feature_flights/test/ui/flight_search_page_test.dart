import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given default selections when Search Flights is tapped then reports '
    'the default origin/destination',
    (tester) async {
      FlightSearchQuery? reported;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: FlightSearchPage(onSearch: (query) => reported = query),
        ),
      );

      expect(find.text(knownAirports[0].label), findsOneWidget);
      expect(find.text(knownAirports[1].label), findsOneWidget);

      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      expect(reported?.origin, knownAirports[0]);
      expect(reported?.destination, knownAirports[1]);
    },
  );

  testWidgets(
    'given the destination field tapped when an airport is picked then the '
    'field updates',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: FlightSearchPage(onSearch: (_) {}),
        ),
      );

      await tester.tap(find.text('To'));
      await tester.pumpAndSettle();

      expect(find.text(knownAirports[2].label), findsOneWidget);
      await tester.tap(find.text(knownAirports[2].label));
      await tester.pumpAndSettle();

      expect(find.text(knownAirports[2].label), findsOneWidget);
    },
  );

  testWidgets('given actions when built then they render in the app bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: FlightSearchPage(
          onSearch: (_) {},
          actions: const [Icon(Icons.logout)],
        ),
      ),
    );

    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
