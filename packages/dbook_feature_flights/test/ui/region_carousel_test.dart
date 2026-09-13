import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    iataCode: 'LHR',
    city: 'Londres',
    country: 'Reino Unido',
    photoUrl: 'https://example.com/lhr.jpg',
    region: 'Europa',
    isPopular: false,
  ),
];

void main() {
  testWidgetsWithMockImages(
    'given destinations when built then one card per distinct region shows',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: RegionCarousel(
              destinations: _destinations,
              onSelectRegion: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('América do Sul'), findsOneWidget);
      expect(find.text('Europa'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a region card tapped when settled then onSelectRegion receives it',
    (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: RegionCarousel(
              destinations: _destinations,
              onSelectRegion: (region) => selected = region,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Europa'));
      await tester.pumpAndSettle();

      expect(selected, 'Europa');
    },
  );
}
