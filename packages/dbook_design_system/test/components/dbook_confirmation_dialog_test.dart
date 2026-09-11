import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given confirm tapped when dialog resolves then returns true', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDbookConfirmationDialog(
                    context,
                    title: 'Cancel booking?',
                    message: 'This cannot be undone.',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel booking?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('given cancel tapped when dialog resolves then returns false', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDbookConfirmationDialog(
                    context,
                    title: 'Cancel booking?',
                    message: 'This cannot be undone.',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
