import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_flights/src/state/price_providers.dart'
    show priceRepositoryProvider;
import 'package:dbook_feature_flights/src/ui/price_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _flight = Flight(
  id: 1,
  flightNumber: 'DB1001',
  airlineIataCode: 'LA',
  airlineName: 'LATAM',
  originIataCode: 'GRU',
  destinationIataCode: 'GIG',
  departureTime: DateTime(2027, 1, 15, 8),
  arrivalTime: DateTime(2027, 1, 15, 9, 10),
  seatClass: SeatClass.economy,
  price: 450,
  availableCapacity: 30,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

class _Prices implements PriceRepository {
  PriceHistory history0 = PriceHistory(
    flightId: 1,
    current: 450,
    lowest: 400,
    highest: 600,
    points: [
      PricePoint(price: 600, changedAt: DateTime(2026, 9, 1)),
      PricePoint(price: 500, changedAt: DateTime(2026, 9, 20)),
      PricePoint(price: 450, changedAt: DateTime(2026, 10, 5)),
    ],
  );
  Object? historyError;
  double? created;

  @override
  Future<PriceHistory> history(int flightId) async {
    if (historyError != null) throw historyError!;
    return history0;
  }

  @override
  Future<List<PriceAlert>> alerts() async => const [];

  @override
  Future<PriceAlert> createAlert({
    required String origin,
    required String destination,
    required DateTime date,
    required double targetPrice,
  }) async {
    created = targetPrice;
    return PriceAlert(
      id: 1,
      origin: origin,
      destination: destination,
      date: date,
      targetPrice: targetPrice,
      active: true,
    );
  }

  @override
  Future<PriceAlert> updateAlert(int id, {double? targetPrice, bool? active}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAlert(int id) => throw UnimplementedError();
}

Widget _app(_Prices fake, {required bool loggedIn}) => ProviderScope(
  overrides: [
    priceRepositoryProvider.overrideWithValue(fake),
    isLoggedInProvider.overrideWithValue(loggedIn),
  ],
  child: MaterialApp(
    theme: DbookTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(child: PriceSection(flight: _flight)),
    ),
  ),
);

void main() {
  testWidgets('given a price history when the section builds then shows the '
      'title and the alert action', (tester) async {
    await tester.pumpWidget(_app(_Prices(), loggedIn: true));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de preço'), findsOneWidget);
    expect(find.text('Criar alerta de preço'), findsOneWidget);
  });

  testWidgets('given a guest when creating an alert then asks to sign in and '
      'does not open the sheet', (tester) async {
    final fake = _Prices();
    await tester.pumpWidget(_app(fake, loggedIn: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar alerta de preço'));
    await tester.pumpAndSettle();

    expect(
      find.text('Entre na sua conta para criar alertas de preço.'),
      findsOneWidget,
    );
    expect(fake.created, isNull);
  });

  testWidgets('given a signed in user when creating an alert with a target '
      'then it is sent to the server', (tester) async {
    final fake = _Prices();
    await tester.pumpWidget(_app(fake, loggedIn: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar alerta de preço'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '400');
    await tester.tap(find.text('Criar alerta'));
    await tester.pumpAndSettle();

    expect(fake.created, 400);
  });
}
