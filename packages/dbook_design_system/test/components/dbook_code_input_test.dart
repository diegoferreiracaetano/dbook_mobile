import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('given a six digit code when built then renders six boxes', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const DbookCodeInput()));

    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('given digits typed box by box when the last is filled then '
      'reports the whole code', (tester) async {
    String? done;
    final changes = <String>[];
    await tester.pumpWidget(
      _app(
        DbookCodeInput(
          onChanged: changes.add,
          onCompleted: (code) => done = code,
        ),
      ),
    );

    final boxes = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(boxes.at(i), '${i + 1}');
      await tester.pump();
    }

    expect(done, '123456');
    expect(changes.last, '123456');
  });

  testWidgets('given a pasted code in the first box when entered then it '
      'spreads over the boxes', (tester) async {
    String? done;
    await tester.pumpWidget(
      _app(DbookCodeInput(onCompleted: (code) => done = code)),
    );

    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pump();

    expect(done, '654321');
  });

  testWidgets('given an error text when built then shows it', (tester) async {
    await tester.pumpWidget(
      _app(const DbookCodeInput(errorText: 'Código inválido')),
    );

    expect(find.text('Código inválido'), findsOneWidget);
  });

  testWidgets('given non digits when typed then they are ignored', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(_app(DbookCodeInput(onChanged: changes.add)));

    await tester.enterText(find.byType(TextField).first, 'a');
    await tester.pump();

    expect(changes.where((c) => c.isNotEmpty), isEmpty);
  });
}
