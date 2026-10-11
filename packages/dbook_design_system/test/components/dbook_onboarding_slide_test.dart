import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given skip and primary action when built then both render and tap fires',
    (tester) async {
      var skipCount = 0;
      var primaryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DbookOnboardingSlide(
              background: const ColoredBox(color: Colors.blue),
              title: 'Descubra novos horizontes',
              subtitle: 'Find and book the best flights.',
              pageCount: 3,
              currentIndex: 0,
              primaryActionLabel: 'Avançar',
              onPrimaryAction: () => primaryCount++,
              onSkip: () => skipCount++,
            ),
          ),
        ),
      );

      expect(find.text('Descubra novos horizontes'), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);

      await tester.tap(find.text('Pular'));
      expect(skipCount, 1);

      await tester.tap(find.text('Avançar'));
      expect(primaryCount, 1);
    },
  );

  testWidgets('given no onSkip when built then Skip does not render', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DbookOnboardingSlide(
            background: const ColoredBox(color: Colors.blue),
            title: 'Viaje do seu jeito',
            subtitle: 'Flexible options, secure booking.',
            pageCount: 3,
            currentIndex: 2,
            primaryActionLabel: 'Começar',
            onPrimaryAction: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pular'), findsNothing);
    expect(find.text('Começar'), findsOneWidget);
  });
}
