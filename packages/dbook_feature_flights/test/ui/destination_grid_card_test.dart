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
  region: 'América do Sul',
  isPopular: true,
);

Widget _app(Widget home) {
  return ProviderScope(
    child: MaterialApp(theme: DbookTheme.light, home: home),
  );
}

class _FixedSearchOrigin extends SearchOriginNotifier {
  _FixedSearchOrigin(this._origin);

  final SearchOrigin? _origin;

  @override
  SearchOrigin? build() => _origin;
}

Widget _gridApp(SearchOrigin? origin, List<Destination> destinations) {
  return ProviderScope(
    overrides: [
      searchOriginProvider.overrideWith(() => _FixedSearchOrigin(origin)),
    ],
    child: MaterialApp(
      theme: DbookTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: DestinationCardGrid(
            destinations: destinations,
            onSelect: (_) {},
          ),
        ),
      ),
    ),
  );
}

const _gig = Destination(
  iataCode: 'GIG',
  city: 'Rio de Janeiro',
  country: 'Brasil',
  photoUrl: 'https://example.com/gig.jpg',
  region: 'América do Sul',
  isPopular: true,
);

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

  testWidgetsWithMockImages(
    'given a destination with a real average rating when built then it '
    'shows the star badge rounded to one decimal',
    (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: DestinationCard(
              destination: _destination.copyWith(averageRating: 4.6667),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a destination nobody reviewed when built then no rating badge '
    'renders',
    (tester) async {
      await tester.pumpWidget(
        _app(Scaffold(body: DestinationCard(destination: _destination))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a search leaving from GRU when the grid builds then GRU is not '
    'offered as a destination, but the others are',
    (tester) async {
      await tester.pumpWidget(
        _gridApp(
          (origin: _destination, date: DateTime(2026, 10, 3)),
          [_destination, _gig],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('São Paulo'), findsNothing);
      expect(find.text('Rio de Janeiro'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given no search origin yet when the grid builds then every destination '
    'is offered',
    (tester) async {
      await tester.pumpWidget(_gridApp(null, [_destination, _gig]));
      await tester.pumpAndSettle();

      expect(find.text('São Paulo'), findsOneWidget);
      expect(find.text('Rio de Janeiro'), findsOneWidget);
    },
  );
}
