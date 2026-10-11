import 'package:dbook_core_network/dbook_core_network.dart';
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

class _FakeFavorites implements FavoriteRepository {
  final saved = <String>{};
  var failOnAdd = false;

  @override
  Future<Set<String>> destinations() async => {...saved};

  @override
  Future<void> addDestination(String iataCode) async {
    if (failOnAdd) throw const DbookConflictException('limite');
    saved.add(iataCode);
  }

  @override
  Future<void> removeDestination(String iataCode) async =>
      saved.remove(iataCode);
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

      expect(find.text('a partir de \$450'), findsOneWidget);
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
      expect(find.textContaining('a partir de \$'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a signed-in user when tapping the favorite then it fills and the '
    'server is told',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fake = _FakeFavorites();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isLoggedInProvider.overrideWithValue(true),
            favoriteRepositoryProvider.overrideWithValue(fake),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const Scaffold(
              body: DestinationCard(destination: _destination),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(fake.saved, {'GRU'});
    },
  );

  testWidgetsWithMockImages(
    'given the server refuses when tapping the favorite then it goes back to '
    'empty',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fake = _FakeFavorites()..failOnAdd = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isLoggedInProvider.overrideWithValue(true),
            favoriteRepositoryProvider.overrideWithValue(fake),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const Scaffold(
              body: DestinationCard(destination: _destination),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
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
