import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_flights/src/state/price_providers.dart'
    show priceRepositoryProvider, priceAlertErrorMessage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PriceAlert _alert(int id, {bool active = true, double target = 900}) =>
    PriceAlert(
      id: id,
      origin: 'GRU',
      destination: 'LIS',
      date: DateTime(2027, 3, 10),
      targetPrice: target,
      active: active,
    );

class _FakePrices implements PriceRepository {
  var alertsList = [_alert(1), _alert(2, active: false)];
  Object? updateError;
  Object? deleteError;
  final deleted = <int>[];

  @override
  Future<PriceHistory> history(int flightId) async => PriceHistory(
    flightId: flightId,
    current: 800,
    lowest: 700,
    highest: 1000,
    points: [
      PricePoint(price: 1000, changedAt: DateTime(2026, 9, 1)),
      PricePoint(price: 900, changedAt: DateTime(2026, 9, 15)),
      PricePoint(price: 800, changedAt: DateTime(2026, 10, 1)),
    ],
  );

  @override
  Future<List<PriceAlert>> alerts() async => alertsList;

  @override
  Future<PriceAlert> createAlert({
    required String origin,
    required String destination,
    required DateTime date,
    required double targetPrice,
  }) async => _alert(9, target: targetPrice);

  @override
  Future<PriceAlert> updateAlert(
    int id, {
    double? targetPrice,
    bool? active,
  }) async {
    if (updateError != null) throw updateError!;
    final current = alertsList.firstWhere((a) => a.id == id);
    return current.copyWith(
      targetPrice: targetPrice ?? current.targetPrice,
      active: active ?? current.active,
    );
  }

  @override
  Future<void> deleteAlert(int id) async {
    if (deleteError != null) throw deleteError!;
    deleted.add(id);
  }
}

ProviderContainer _container(_FakePrices fake) {
  final container = ProviderContainer(
    overrides: [priceRepositoryProvider.overrideWithValue(fake)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given an active alert when switching it off then updates and keeps '
      'the server answer', () async {
    final container = _container(_FakePrices());
    container.listen(priceAlertsNotifierProvider, (_, _) {});
    await container.read(priceAlertsNotifierProvider.future);
    final notifier = container.read(priceAlertsNotifierProvider.notifier);

    await notifier.setActive(_alert(1), active: false);

    final state = container.read(priceAlertsNotifierProvider).value!;
    expect(state.firstWhere((a) => a.id == 1).active, isFalse);
  });

  test('given the server refuses when changing the target then goes back '
      'and rethrows', () async {
    final fake = _FakePrices()
      ..updateError = const DbookConflictException('limite');
    final container = _container(fake);
    container.listen(priceAlertsNotifierProvider, (_, _) {});
    await container.read(priceAlertsNotifierProvider.future);
    final notifier = container.read(priceAlertsNotifierProvider.notifier);

    await expectLater(
      notifier.setTarget(_alert(1), 500),
      throwsA(isA<DbookConflictException>()),
    );

    final state = container.read(priceAlertsNotifierProvider).value!;
    expect(state.firstWhere((a) => a.id == 1).targetPrice, 900);
  });

  test('given an alert when deleting then it leaves the list and the server '
      'is told', () async {
    final fake = _FakePrices();
    final container = _container(fake);
    container.listen(priceAlertsNotifierProvider, (_, _) {});
    await container.read(priceAlertsNotifierProvider.future);
    final notifier = container.read(priceAlertsNotifierProvider.notifier);

    await notifier.delete(_alert(2));

    expect(fake.deleted, [2]);
    expect(
      container.read(priceAlertsNotifierProvider).value!.map((a) => a.id),
      [1],
    );
  });

  test('given a price below the average when reading the trend then it is '
      'below', () async {
    final history = await _FakePrices().history(1);

    expect(history.trend, PriceTrend.below);
    expect(history.average, closeTo(900, 0.001));
  });

  test('given the limit code when explaining then says to turn one off', () {
    expect(
      priceAlertErrorMessage(
        const DbookConflictException('x', code: 'PRICE_ALERTS_LIMIT'),
      ),
      contains('20 alertas'),
    );
  });

  testWidgets('given alerts when the page builds then lists the routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [priceRepositoryProvider.overrideWithValue(_FakePrices())],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: const PriceAlertsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('GRU'), findsWidgets);
    expect(find.textContaining('LIS'), findsWidgets);
  });

  testWidgets('given an alert when switching it off in the list then the '
      'server is asked to deactivate it', (tester) async {
    final fake = _FakePrices();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [priceRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: const PriceAlertsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.first.value, isFalse);
  });

  testWidgets('given an alert when deleting it in the list then it goes '
      'away', (tester) async {
    final fake = _FakePrices();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [priceRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: const PriceAlertsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Apagar alerta').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar').last);
    await tester.pumpAndSettle();

    expect(fake.deleted, [1]);
  });

  testWidgets('given the server refuses the change when switching then '
      'the switch goes back and the message is shown', (tester) async {
    final fake = _FakePrices()
      ..updateError = const DbookConflictException(
        'x',
        code: 'PRICE_ALERTS_LIMIT',
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [priceRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: DbookTheme.light,
          home: const PriceAlertsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(find.textContaining('20 alertas'), findsOneWidget);
    expect(tester.widgetList<Switch>(find.byType(Switch)).last.value, isFalse);
  });
}
