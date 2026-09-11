import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given the default info tone when built then message renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DbookInlineStatusBanner(
            message: 'Disponibilidade em tempo real',
          ),
        ),
      ),
    );

    expect(find.text('Disponibilidade em tempo real'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets(
    'given the warning tone when built then the warning icon renders',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookInlineStatusBanner(
              message: 'Poucos assentos restantes',
              tone: DbookBannerTone.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    },
  );
}
