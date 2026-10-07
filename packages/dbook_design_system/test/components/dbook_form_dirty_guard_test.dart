import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openForm(WidgetTester tester, {required bool dirty}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DbookTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DbookFormDirtyGuard(
                  isDirty: dirty,
                  child: const Scaffold(body: Text('Formulário')),
                ),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('given a clean form when going back then it leaves without '
      'asking', (tester) async {
    await _openForm(tester, dirty: false);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Formulário'), findsNothing);
    expect(find.text('Descartar alterações?'), findsNothing);
  });

  testWidgets('given a dirty form when going back then it asks first and '
      'stays', (tester) async {
    await _openForm(tester, dirty: true);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Descartar alterações?'), findsOneWidget);
    expect(find.text('Formulário'), findsOneWidget);
  });

  testWidgets('given the question when "Continuar editando" is tapped then '
      'the form stays', (tester) async {
    await _openForm(tester, dirty: true);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();

    expect(find.text('Formulário'), findsOneWidget);
    expect(find.text('Descartar alterações?'), findsNothing);
  });

  testWidgets('given the question when "Descartar" is tapped then the form '
      'closes', (tester) async {
    await _openForm(tester, dirty: true);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();

    expect(find.text('Formulário'), findsNothing);
  });
}
