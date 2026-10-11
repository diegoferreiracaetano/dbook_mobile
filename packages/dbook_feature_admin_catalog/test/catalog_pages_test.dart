import 'dart:convert';
import 'dart:io';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_catalog/dbook_feature_admin_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

void main() {
  flightFormFlows();

  testWidgets('given real flights when the list builds then shows the '
      'flight number', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({
        '/admin/flights': 'flights',
        '/admin/airlines': 'airlines',
        '/admin/airports': 'airports',
      }),
      child: FlightsPage(
        query: defaultFlightQuery,
        onQueryChanged: (_) {},
        onOpen: (_) {},
        onCreate: () {},
        onImport: () {},
      ),
    );

    expect(find.text('DB1001'), findsWidgets);
  });

  testWidgets('given real airlines when the page builds then lists them', (
    tester,
  ) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/airlines': 'airlines'}),
      child: const AirlinesPage(),
    );

    expect(find.text('LATAM Airlines'), findsWidgets);
  });

  testWidgets('given real airports when the page builds then lists the '
      'cities', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/airports': 'airports'}),
      child: const AirportsPage(),
    );

    expect(find.text('Rio de Janeiro'), findsWidgets);
  });

  testWidgets('given a real flight when the edit form builds then loads it '
      'without errors', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({
        '/admin/flights/1': 'flight_detail',
        '/admin/airlines': 'airlines',
        '/admin/airports': 'airports',
        '/admin/aircraft-models': 'aircraft_models',
      }),
      child: FlightFormPage(id: 1, onBack: () {}, onSaved: (_) {}),
    );

    expect(find.text('DB1001'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

void flightFormFlows() {
  Object fx(String name) =>
      jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Object;

  Map<String, Object> replies() => {
    '/admin/flights/1': fx('flight_detail'),
    '/admin/airlines': fx('airlines'),
    '/admin/airports': fx('airports'),
    '/admin/aircraft-models': fx('aircraft_models'),
  };

  testWidgets('given a flight when changing the price and saving then sends '
      'the version it loaded', (tester) async {
    final recorder = RecordingDio(replies: replies());
    var saved = false;
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: FlightFormPage(id: 1, onBack: () {}, onSaved: (_) => saved = true),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço (R\$)'),
      '480',
    );
    await tester.ensureVisible(find.text('Salvar voo'));
    await tester.tap(find.text('Salvar voo'));
    await tester.pumpAndSettle();

    final puts = recorder.to('PUT', '/admin/flights/1').toList();
    expect(puts, hasLength(1));
    expect((puts.single.data as Map)['version'], 0);
    expect((puts.single.data as Map)['price'], 480);
    expect(saved, isTrue);
  });

  testWidgets('given a scheduled flight when cancelling after confirming '
      'then posts the cancel', (tester) async {
    final detail = Map<String, Object?>.from(
      fx('flight_detail') as Map<String, dynamic>,
    )..['activeBookings'] = 0;
    final recorder = RecordingDio(
      replies: {...replies(), 'GET /admin/flights/1': detail as Object},
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: FlightFormPage(id: 1, onBack: () {}, onSaved: (_) {}),
    );

    await tester.ensureVisible(find.text('Cancelar voo'));
    await tester.tap(find.text('Cancelar voo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar voo').last);
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/flights/1/cancel'), hasLength(1));
  });

  testWidgets('given a concurrent edit when keeping mine then saves again '
      'on top of the latest version', (tester) async {
    final recorder = RecordingDio(
      replies: replies(),
      failures: {
        'PUT /admin/flights/1': (
          status: 409,
          body: {'error': 'stale', 'code': 'STALE_VERSION'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: FlightFormPage(id: 1, onBack: () {}, onSaved: (_) {}),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço (R\$)'),
      '480',
    );
    await tester.ensureVisible(find.text('Salvar voo'));
    await tester.tap(find.text('Salvar voo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar as minhas mudanças por cima'));
    await tester.tap(find.text('Salvar as minhas mudanças por cima'));
    await tester.pumpAndSettle();

    expect(recorder.to('PUT', '/admin/flights/1'), hasLength(2));
  });

  testWidgets('given a concurrent edit when a server answers '
      'STALE_VERSION then the form offers to reload or keep mine', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: replies(),
      failures: {
        'PUT /admin/flights/1': (
          status: 409,
          body: {'error': 'stale', 'code': 'STALE_VERSION'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: FlightFormPage(id: 1, onBack: () {}, onSaved: (_) {}),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço (R\$)'),
      '480',
    );
    await tester.ensureVisible(find.text('Salvar voo'));
    await tester.tap(find.text('Salvar voo'));
    await tester.pumpAndSettle();

    expect(find.text('Recarregar e descartar minhas mudanças'), findsOneWidget);
  });
}
