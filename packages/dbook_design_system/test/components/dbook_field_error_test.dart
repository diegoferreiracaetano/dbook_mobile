import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given a message when built then shows it in the error color '
      'as a live region', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(body: DbookFieldError('Algo deu errado')),
      ),
    );

    final text = tester.widget<Text>(find.text('Algo deu errado'));
    expect(text.style!.color, DbookColorScheme.light.error);
    expect(
      tester.getSemantics(find.text('Algo deu errado')).label,
      'Algo deu errado',
    );
  });
}
