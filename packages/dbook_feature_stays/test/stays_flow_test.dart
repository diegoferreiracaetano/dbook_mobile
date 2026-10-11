import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_stays/dbook_feature_stays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccommodations implements AccommodationRepository {
  List<AccommodationResult> results = [
    const AccommodationResult(
      id: 7,
      name: 'Hotel Copacabana',
      city: 'Rio de Janeiro',
      destinationIataCode: 'GIG',
      address: 'Av. Atlântica, 1000',
      stars: 4,
      amenities: ['wifi'],
      fromPrice: 1050,
      rooms: [
        RoomOffer(
          roomTypeId: 3,
          name: 'Quarto duplo',
          capacity: 2,
          nightlyRate: 350,
          totalPrice: 1050,
        ),
      ],
    ),
  ];
  DbookNetworkException? bookError;
  StaySearch? lastSearch;
  int? bookedRoom;

  @override
  Future<List<AccommodationResult>> search(StaySearch search) async {
    lastSearch = search;
    return results;
  }

  @override
  Future<AccommodationDetail> detail(int id) async => const AccommodationDetail(
    id: 7,
    name: 'Hotel Copacabana',
    city: 'Rio de Janeiro',
    destinationIataCode: 'GIG',
    address: 'Av. Atlântica, 1000',
    stars: 4,
    amenities: ['wifi'],
    roomTypes: [
      RoomType(id: 3, name: 'Quarto duplo', capacity: 2, nightlyRate: 350),
    ],
  );

  @override
  Future<int> book({
    required int accommodationId,
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    if (bookError != null) throw bookError!;
    bookedRoom = roomTypeId;
    return 91;
  }

  List<StayBooking> stays = const [];
  Object? staysError;

  @override
  Future<List<StayBooking>> myStays() async {
    if (staysError != null) throw staysError!;
    return stays;
  }
}

Widget _app(_FakeAccommodations fake, Widget home) => ProviderScope(
  overrides: [accommodationRepositoryProvider.overrideWithValue(fake)],
  child: MaterialApp(theme: DbookTheme.light, home: home),
);

const _rio = Destination(
  iataCode: 'GIG',
  city: 'Rio de Janeiro',
  country: 'Brasil',
  photoUrl: '',
  region: 'Americas',
  isPopular: true,
);

Widget _panel({bool pick = true}) => Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [
        StaySearchCard(
          destinations: const [_rio],
          pickDestination: (context, list) async => pick ? list.first : null,
        ),
        StaySearchResults(
          isLoggedIn: true,
          onRequireLogin: () {},
          onCheckout: (_) {},
        ),
      ],
    ),
  ),
);

StaySearch get _search => StaySearch(
  destination: 'GIG',
  checkIn: DateTime(2027, 1, 15),
  checkOut: DateTime(2027, 1, 18),
  guests: 2,
);

void main() {
  testWidgets('given no dates when searching then asks for them and does not '
      'call the server', (tester) async {
    final fake = _FakeAccommodations();
    await tester.pumpWidget(_app(fake, _panel()));

    await tester.tap(find.text('Selecionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar hotéis'));
    await tester.pump();

    expect(find.text('Escolha entrada e saída em dias diferentes.'), findsOne);
    expect(fake.lastSearch, isNull);
  });

  testWidgets('given no destination when searching then shows the '
      'validation message', (tester) async {
    await tester.pumpWidget(_app(_FakeAccommodations(), _panel()));

    await tester.tap(find.text('Buscar hotéis'));
    await tester.pump();

    expect(find.text('Escolha o destino.'), findsOne);
  });

  testWidgets('given a room when booking then delivers the checkout with the '
      'server booking id and total', (tester) async {
    final fake = _FakeAccommodations();
    StayCheckout? checkout;
    await tester.pumpWidget(
      _app(
        fake,
        StayDetailPage(
          hotelId: 7,
          search: _search,
          isLoggedIn: true,
          onRequireLogin: () {},
          onCheckout: (c) => checkout = c,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservar'));
    await tester.pumpAndSettle();

    expect(fake.bookedRoom, 3);
    expect(checkout!.bookingId, 91);
    expect(checkout!.price, 1050);
    expect(checkout!.label, contains('Hotel Copacabana'));
  });

  testWidgets('given a guest when booking then asks to sign in instead of '
      'calling the server', (tester) async {
    final fake = _FakeAccommodations();
    var asked = false;
    await tester.pumpWidget(
      _app(
        fake,
        StayDetailPage(
          hotelId: 7,
          search: _search,
          isLoggedIn: false,
          onRequireLogin: () => asked = true,
          onCheckout: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservar'));
    await tester.pump();

    expect(asked, isTrue);
    expect(fake.bookedRoom, isNull);
  });

  testWidgets('given a room that filled up when booking then shows the '
      'server message', (tester) async {
    final fake = _FakeAccommodations()
      ..bookError = const DbookConflictException('Quarto indisponível');
    await tester.pumpWidget(
      _app(
        fake,
        StayDetailPage(
          hotelId: 7,
          search: _search,
          isLoggedIn: true,
          onRequireLogin: () {},
          onCheckout: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservar'));
    await tester.pumpAndSettle();

    expect(find.text('Quarto indisponível'), findsOne);
  });

  testWidgets('given destination and a picked range when searching then '
      'lists the hotels the server returned', (tester) async {
    final fake = _FakeAccommodations();
    await tester.pumpWidget(_app(fake, _panel()));

    await tester.tap(find.text('Selecionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrada'));
    await tester.pumpAndSettle();
    final today = DateTime.now();
    final first = today.day < 25 ? today.day + 2 : today.day;
    await tester.tap(find.text('$first').first);
    await tester.pump();
    await tester.tap(find.text('${first + 3 > 28 ? 28 : first + 3}').first);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 hóspedes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mais um hóspede'));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar hotéis'));
    await tester.pumpAndSettle();

    expect(fake.lastSearch!.destination, 'GIG');
    expect(fake.lastSearch!.guests, 3);
    expect(find.text('Hotel Copacabana'), findsOneWidget);
  });

  StayBooking stay(String status) => StayBooking(
    bookingId: 2,
    status: status,
    hotelName: 'Hotel Copacabana',
    city: 'Rio de Janeiro',
    checkIn: DateTime(2027, 1, 15),
    checkOut: DateTime(2027, 1, 18),
    nights: 3,
    guests: 2,
    price: 1050,
  );

  testWidgets('given stays when the list builds then shows each with its '
      'status and total', (tester) async {
    final fake = _FakeAccommodations()
      ..stays = [stay('CONFIRMED'), stay('PENDING'), stay('REFUNDED')];
    await tester.pumpWidget(_app(fake, const MyStaysPage()));
    await tester.pumpAndSettle();

    expect(find.text('Hotel Copacabana'), findsNWidgets(3));
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Reembolsada'), findsOneWidget);
  });

  testWidgets('given no stays when the list builds then shows the empty '
      'state', (tester) async {
    await tester.pumpWidget(_app(_FakeAccommodations(), const MyStaysPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma estadia ainda'), findsOneWidget);
  });

  testWidgets('given the server fails when the list builds then shows the '
      'error with retry', (tester) async {
    final fake = _FakeAccommodations()
      ..staysError = const DbookUnknownNetworkException('sem rede');
    await tester.pumpWidget(_app(fake, const MyStaysPage()));
    await tester.pumpAndSettle();

    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('given a pending stay when tapping pay now then hands over the '
      'booking id and total', (tester) async {
    final fake = _FakeAccommodations()
      ..stays = [stay('PENDING'), stay('CONFIRMED')];
    StayCheckout? paid;
    await tester.pumpWidget(
      _app(fake, Scaffold(body: MyStaysList(onPay: (c) => paid = c))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pagar agora'), findsOneWidget);
    await tester.tap(find.text('Pagar agora'));

    expect(paid!.bookingId, 2);
    expect(paid!.price, 1050);
    expect(paid!.label, contains('Hotel Copacabana'));
  });
}
