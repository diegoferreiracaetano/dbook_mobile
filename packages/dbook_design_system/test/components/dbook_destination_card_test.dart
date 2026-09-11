import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given title, subtitle and tap when tapped then onTap fires', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookDestinationCard(
            title: 'Madri, Espanha',
            subtitle: 'a partir de R\$480',
            background: const BoxDecoration(color: Colors.blue),
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    expect(find.text('Madri, Espanha'), findsOneWidget);
    expect(find.text('a partir de R\$480'), findsOneWidget);

    await tester.tap(find.byType(DbookDestinationCard));
    expect(tapCount, 1);
  });
}
