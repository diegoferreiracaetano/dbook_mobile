import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool?> _show(
  WidgetTester tester, {
  DbookConfirmLevel level = DbookConfirmLevel.simple,
  String? phrase,
}) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: DbookTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async => result = await showDbookConfirmationDialog(
              context,
              title: 'Apagar dados',
              message: 'Não dá para desfazer.',
              confirmLabel: 'Apagar',
              level: level,
              confirmationPhrase: phrase,
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('given a destructive level when built then the confirm button '
      'uses the error color', (tester) async {
    await _show(tester, level: DbookConfirmLevel.destructive);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Apagar'),
    );
    final background = button.style!.backgroundColor!.resolve({});
    expect(background, DbookColorScheme.light.error);
  });

  testWidgets('given a destructive level when confirmed then returns true', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async => result = await showDbookConfirmationDialog(
                context,
                title: 'Bloquear',
                message: 'Bloquear este cliente?',
                level: DbookConfirmLevel.destructive,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  group('typed phrase', () {
    testWidgets('given no text typed when built then confirm is disabled and '
        'the phrase is shown', (tester) async {
      await _show(
        tester,
        level: DbookConfirmLevel.typedPhrase,
        phrase: 'APAGAR DIEGO',
      );

      expect(find.text('Digite "APAGAR DIEGO" para confirmar'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Apagar'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('given a wrong phrase when typed then confirm stays '
        'disabled', (tester) async {
      await _show(
        tester,
        level: DbookConfirmLevel.typedPhrase,
        phrase: 'APAGAR DIEGO',
      );

      await tester.enterText(find.byType(TextField), 'apagar diego');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Apagar'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('given the exact phrase when typed then confirm enables and '
        'returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async =>
                    result = await showDbookConfirmationDialog(
                      context,
                      title: 'Apagar dados',
                      message: 'Não dá para desfazer.',
                      confirmLabel: 'Apagar',
                      level: DbookConfirmLevel.typedPhrase,
                      confirmationPhrase: 'APAGAR DIEGO',
                    ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'APAGAR DIEGO');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apagar'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
