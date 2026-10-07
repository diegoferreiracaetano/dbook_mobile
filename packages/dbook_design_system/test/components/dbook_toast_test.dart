import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(void Function(BuildContext) onTap) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => onTap(context),
        child: const Text('Disparar'),
      ),
    ),
  ),
);

void main() {
  testWidgets('given a danger toast when shown then it has the message and '
      'an icon, not only a color', (tester) async {
    await tester.pumpWidget(
      _app(
        (c) =>
            showDbookToast(c, 'Falha ao bloquear', tone: DbookToastTone.danger),
      ),
    );

    await tester.tap(find.text('Disparar'));
    await tester.pump();

    expect(find.text('Falha ao bloquear'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('given a toast when its duration passes then it goes away', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        (c) => showDbookToast(c, 'Salvo', duration: const Duration(seconds: 2)),
      ),
    );

    await tester.tap(find.text('Disparar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Salvo'), findsNothing);
  });

  testWidgets('given the undo snackbar when "Desfazer" is tapped then it '
      'resolves true', (tester) async {
    bool? undone;
    await tester.pumpWidget(
      _app(
        (c) async =>
            undone = await showDbookUndoSnackbar(c, 'Reserva cancelada'),
      ),
    );

    await tester.tap(find.text('Disparar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(undone, isTrue);
  });

  testWidgets('given the undo snackbar when it times out then it resolves '
      'false and the caller commits', (tester) async {
    bool? undone;
    await tester.pumpWidget(
      _app(
        (c) async => undone = await showDbookUndoSnackbar(
          c,
          'Reserva cancelada',
          duration: const Duration(seconds: 2),
        ),
      ),
    );

    await tester.tap(find.text('Disparar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(undone, isFalse);
  });
}
