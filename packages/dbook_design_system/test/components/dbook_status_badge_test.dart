import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given confirmed status when built then uses the success color pair',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookStatusBadge(
              status: DbookStatus.confirmed,
              label: 'Confirmada',
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Confirmada'));
      expect(text.style!.color, DbookStatusColors.light.success);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, DbookStatusColors.light.successContainer);
    },
  );

  testWidgets(
    'given cancelled status when built then uses the ColorScheme error color pair',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: DbookStatusBadge(
              status: DbookStatus.cancelled,
              label: 'Cancelada',
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Cancelada'));
      expect(text.style!.color, DbookColorScheme.light.error);
    },
  );
}
