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
              background: const BoxDecoration(color: Colors.blue),
              title: 'Discover New Horizons',
              subtitle: 'Find and book the best flights.',
              pageCount: 3,
              currentIndex: 0,
              primaryActionLabel: 'Next',
              onPrimaryAction: () => primaryCount++,
              onSkip: () => skipCount++,
            ),
          ),
        ),
      );

      expect(find.text('Discover New Horizons'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      expect(skipCount, 1);

      await tester.tap(find.text('Next'));
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
            background: const BoxDecoration(color: Colors.blue),
            title: 'Travel Your Way',
            subtitle: 'Flexible options, secure booking.',
            pageCount: 3,
            currentIndex: 2,
            primaryActionLabel: 'Get Started',
            onPrimaryAction: () {},
          ),
        ),
      ),
    );

    expect(find.text('Skip'), findsNothing);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
