import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mock_network_image.dart';

const _destination = Destination(
  iataCode: 'GRU',
  city: 'São Paulo',
  country: 'Brasil',
  photoUrl: 'https://example.com/gru.jpg',
);

Widget _app(Widget home) {
  return ProviderScope(
    child: MaterialApp(theme: DbookTheme.light, home: home),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgetsWithMockImages(
    'given a destination with a real lowest price when built then it shows '
    "the 'from \$X' badge",
    (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: DestinationCard(
              destination: _destination.copyWith(lowestPrice: 450),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('from \$450'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a destination with no flights when built then no price badge '
    'renders',
    (tester) async {
      await tester.pumpWidget(
        _app(Scaffold(body: DestinationCard(destination: _destination))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.textContaining('from \$'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given the favorite button when tapped then it toggles filled and '
    'persists',
    (tester) async {
      await tester.pumpWidget(
        _app(Scaffold(body: DestinationCard(destination: _destination))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_destination_iata_codes'), [
        _destination.iataCode,
      ]);
    },
  );
}
