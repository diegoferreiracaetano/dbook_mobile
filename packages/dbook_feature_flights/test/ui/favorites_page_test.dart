import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mock_network_image.dart';

const _gig = Destination(
  iataCode: 'GIG',
  city: 'Rio de Janeiro',
  country: 'Brasil',
  photoUrl: 'https://example.com/gig.jpg',
  region: 'América do Sul',
  isPopular: true,
);
const _jfk = Destination(
  iataCode: 'JFK',
  city: 'New York',
  country: 'Estados Unidos',
  photoUrl: 'https://example.com/jfk.jpg',
  region: 'América do Norte',
  isPopular: true,
);

class _Destinations implements DestinationRepository {
  @override
  Future<List<Destination>> getFeaturedDestinations() async => [_gig, _jfk];
}

class _Favorites implements FavoriteRepository {
  _Favorites(this.codes);

  final Set<String> codes;

  @override
  Future<Set<String>> destinations() async => codes;

  @override
  Future<void> addDestination(String code) async => codes.add(code);

  @override
  Future<void> removeDestination(String code) async => codes.remove(code);
}

Widget _app(Set<String> codes, ValueChanged<Destination> onSelect) {
  SharedPreferences.setMockInitialValues({
    'favorites_migrated_to_server': true,
  });
  return ProviderScope(
    overrides: [
      isLoggedInProvider.overrideWithValue(true),
      destinationRepositoryProvider.overrideWithValue(_Destinations()),
      favoriteRepositoryProvider.overrideWithValue(_Favorites(codes)),
    ],
    child: MaterialApp(
      theme: DbookTheme.light,
      home: FavoritesPage(onSelectDestination: onSelect),
    ),
  );
}

void main() {
  testWidgetsWithMockImages(
    'given no favorites when the page opens then shows the empty state',
    (tester) async {
      await tester.pumpWidget(_app({}, (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('Sua lista está vazia'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a favorite when the page opens then lists only it and tapping '
    'selects it',
    (tester) async {
      Destination? picked;
      await tester.pumpWidget(_app({'GIG'}, (d) => picked = d));
      await tester.pumpAndSettle();

      expect(find.text('Rio de Janeiro'), findsOneWidget);
      expect(find.text('New York'), findsNothing);

      await tester.tap(find.text('Rio de Janeiro'));

      expect(picked?.iataCode, 'GIG');
    },
  );
}
