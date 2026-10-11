import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_stays/dbook_feature_stays.dart';
import 'package:dbook_mobile/home_stays_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Accommodations implements AccommodationRepository {
  _Accommodations(this.results);

  final List<AccommodationResult> results;
  final searched = <String>[];

  @override
  Future<List<AccommodationResult>> search(StaySearch search) async {
    searched.add(search.destination);
    return search.destination == 'LIS' ? results : const [];
  }

  @override
  Future<AccommodationDetail> detail(int id) async => const AccommodationDetail(
    id: 7,
    name: 'Hotel Alfama',
    city: 'Lisboa',
    destinationIataCode: 'LIS',
    address: 'Rua 1',
    stars: 4,
    amenities: [],
    roomTypes: [RoomType(id: 3, name: 'Duplo', capacity: 2, nightlyRate: 100)],
  );

  @override
  Future<int> book({
    required int accommodationId,
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) => throw UnimplementedError();

  @override
  Future<List<StayBooking>> myStays() async => const [];
}

const _hotel = AccommodationResult(
  id: 7,
  name: 'Hotel Alfama',
  city: 'Lisboa',
  destinationIataCode: 'LIS',
  address: 'Rua 1',
  stars: 4,
  amenities: [],
  fromPrice: 200,
  rooms: [],
);

const _lisbon = Destination(
  iataCode: 'LIS',
  city: 'Lisboa',
  country: 'Portugal',
  photoUrl: '',
  region: 'Europa',
  isPopular: true,
  lowestPrice: 900,
);

Widget _section(
  _Accommodations fake,
  List<Destination> destinations, {
  void Function(Destination)? onFlights,
}) => ProviderScope(
  overrides: [accommodationRepositoryProvider.overrideWithValue(fake)],
  child: MaterialApp(
    theme: DbookTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        child: HomeStaysSection(
          destinations: destinations,
          isLoggedIn: true,
          onRequireLogin: () {},
          onCheckout: (_) {},
          onSearchFlights: onFlights ?? (_) {},
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('given destinations with hotels when built then shows the '
      'carousel and a package with both real prices', (tester) async {
    final fake = _Accommodations(const [_hotel]);
    await tester.pumpWidget(_section(fake, const [_lisbon]));
    await tester.pumpAndSettle();

    expect(find.text('HOTÉIS EM DESTAQUE'), findsOneWidget);
    expect(find.text('Hotel Alfama'), findsOneWidget);
    expect(find.text('PACOTES VOO + HOTEL'), findsOneWidget);
    expect(find.textContaining('Voo a partir de'), findsOneWidget);
    expect(fake.searched, ['LIS']);
  });

  testWidgets('given a package when tapping the flights button then asks for '
      'the flights of that destination', (tester) async {
    Destination? asked;
    await tester.pumpWidget(
      _section(_Accommodations(const [_hotel]), const [
        _lisbon,
      ], onFlights: (d) => asked = d),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver voos'));

    expect(asked?.iataCode, 'LIS');
  });

  testWidgets('given a package when tapping the hotel button then opens the '
      'hotel detail', (tester) async {
    await tester.pumpWidget(
      _section(_Accommodations(const [_hotel]), const [_lisbon]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver hotel'));
    await tester.pumpAndSettle();

    expect(find.byType(StayDetailPage), findsOneWidget);
  });

  testWidgets('given no hotels at the destinations when built then shows '
      'nothing', (tester) async {
    await tester.pumpWidget(
      _section(_Accommodations(const []), const [_lisbon]),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOTÉIS EM DESTAQUE'), findsNothing);
  });
}
