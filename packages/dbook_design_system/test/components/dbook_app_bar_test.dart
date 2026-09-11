import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given only a title when built then just the title renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          appBar: const DbookAppBar(title: 'Destinations'),
          body: const SizedBox(),
        ),
      ),
    );

    expect(find.text('Destinations'), findsOneWidget);
  });

  testWidgets(
    'given a subtitle when built then both title and subtitle render',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            appBar: const DbookAppBar(
              title: 'Madrid, Spain',
              subtitle: 'Tue, Jan 13, 2026',
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Madrid, Spain'), findsOneWidget);
      expect(find.text('Tue, Jan 13, 2026'), findsOneWidget);
    },
  );

  testWidgets(
    'given transparent true when built then the background is transparent',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            appBar: const DbookAppBar(
              title: 'Flight Details',
              transparent: true,
            ),
            body: const SizedBox(),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.transparent);
    },
  );
}
