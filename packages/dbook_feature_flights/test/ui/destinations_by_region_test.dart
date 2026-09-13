import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mock_network_image.dart';

const _destinations = [
  Destination(
    iataCode: 'GRU',
    city: 'São Paulo',
    country: 'Brasil',
    photoUrl: 'https://example.com/gru.jpg',
    region: 'América do Sul',
    isPopular: true,
  ),
  Destination(
    iataCode: 'GIG',
    city: 'Rio de Janeiro',
    country: 'Brasil',
    photoUrl: 'https://example.com/gig.jpg',
    region: 'América do Sul',
    isPopular: false,
  ),
  Destination(
    iataCode: 'LHR',
    city: 'Londres',
    country: 'Reino Unido',
    photoUrl: 'https://example.com/lhr.jpg',
    region: 'Europa',
    isPopular: false,
  ),
];

Widget _app(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: DbookTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgetsWithMockImages(
    'given no region selected when built then every destination shows',
    (tester) async {
      await tester.pumpWidget(
        _app(
          DestinationsByRegion(destinations: _destinations, onSelect: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('América do Sul'), findsOneWidget);
      expect(find.text('Europa'), findsOneWidget);
      expect(find.text('São Paulo'), findsOneWidget);
      expect(find.text('Rio de Janeiro'), findsOneWidget);
      expect(find.text('Londres'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a region chip tapped when settled then only that region shows',
    (tester) async {
      await tester.pumpWidget(
        _app(
          DestinationsByRegion(destinations: _destinations, onSelect: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Europa'));
      await tester.pumpAndSettle();

      expect(find.text('Londres'), findsOneWidget);
      expect(find.text('São Paulo'), findsNothing);
      expect(find.text('Rio de Janeiro'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a filtered region when Todos is tapped again then every '
    'destination shows again',
    (tester) async {
      await tester.pumpWidget(
        _app(
          DestinationsByRegion(destinations: _destinations, onSelect: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Europa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.text('São Paulo'), findsOneWidget);
      expect(find.text('Rio de Janeiro'), findsOneWidget);
      expect(find.text('Londres'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a destination tapped when settled then onSelect receives it',
    (tester) async {
      Destination? selected;

      await tester.pumpWidget(
        _app(
          DestinationsByRegion(
            destinations: _destinations,
            onSelect: (destination) => selected = destination,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Londres'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Londres'));
      await tester.pumpAndSettle();

      expect(selected, _destinations[2]);
    },
  );
}
