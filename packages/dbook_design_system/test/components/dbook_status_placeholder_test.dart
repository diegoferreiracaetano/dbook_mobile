import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given title and message when built then both render with the icon',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookStatusPlaceholder(
              icon: Icons.search_off,
              title: 'Nenhum voo encontrado',
              message: 'Tente outra data ou destino.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Nenhum voo encontrado'), findsOneWidget);
      expect(find.text('Tente outra data ou destino.'), findsOneWidget);
      expect(find.byType(DbookButton), findsNothing);
    },
  );

  testWidgets('given an action when tapped then onAction fires', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookStatusPlaceholder(
            icon: Icons.error_outline,
            title: 'Algo deu errado',
            message: 'Não foi possível carregar os dados.',
            actionLabel: 'Tentar de novo',
            onAction: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tentar de novo'));
    expect(tapCount, 1);
  });
}
