import 'dart:convert';
import 'dart:io';

import 'package:dbook_feature_admin_catalog/dbook_feature_admin_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

Object _fx(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Object;

void main() {
  testWidgets('given the airlines when adding one then posts the upper cased '
      'code and name', (tester) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airlines': _fx('airlines')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirlinesPage());

    await tester.tap(find.text('Nova companhia').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Código IATA (2 letras ou números)'),
      'g3',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Gol Linhas Aéreas',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/airlines').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['iataCode'], 'G3');
    expect((posts.single.data as Map)['name'], 'Gol Linhas Aéreas');
  });

  testWidgets('given an invalid airline code when saving then shows the '
      'validation and does not call the server', (tester) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airlines': _fx('airlines')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirlinesPage());

    await tester.tap(find.text('Nova companhia').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Código IATA (2 letras ou números)'),
      'ABC',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'X');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/airlines'), isEmpty);
  });

  testWidgets('given the airports when adding one then posts it with the '
      'three letter code', (tester) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airports': _fx('airports')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirportsPage());

    await tester.tap(find.text('Novo aeroporto').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Código IATA (3 letras)'),
      'cwb',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Afonso Pena',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cidade'),
      'Curitiba',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'País'),
      'Brasil',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Região'),
      'América do Sul',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Endereço da foto'),
      'https://example.com/cwb.jpg',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/airports').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['iataCode'], 'CWB');
  });

  testWidgets('given an airline when deleting after confirming then calls '
      'delete', (tester) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airlines': _fx('airlines')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirlinesPage());

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover').last);
    await tester.pumpAndSettle();

    final deletes = recorder.calls.where((c) => c.method == 'DELETE');
    expect(deletes, hasLength(1));
    expect(deletes.single.path, startsWith('/admin/airlines/'));
  });

  testWidgets('given an airline when editing the name then puts the change', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airlines': _fx('airlines')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirlinesPage());

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Nome novo da companhia',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final puts = recorder.calls.where((c) => c.method == 'PUT');
    expect(puts, hasLength(1));
    expect((puts.single.data as Map)['name'], 'Nome novo da companhia');
  });

  testWidgets('given an airport when deleting after confirming then calls '
      'delete', (tester) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/airports': _fx('airports')},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const AirportsPage());

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover').last);
    await tester.pumpAndSettle();

    final deletes = recorder.calls.where((c) => c.method == 'DELETE');
    expect(deletes, hasLength(1));
    expect(deletes.single.path, startsWith('/admin/airports/'));
  });
}
