import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: DbookTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'given label and icon when built then renders both in that order',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          DbookButton(
            label: 'Buscar voos',
            icon: Icons.search,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Buscar voos'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    },
  );

  testWidgets('given onPressed when tapped then callback fires', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _wrap(DbookButton(label: 'Confirmar', onPressed: () => tapCount++)),
    );

    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets(
    'given isLoading true when built then hides label and disables tap',
    (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          DbookButton(
            label: 'Confirmar',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      );

      expect(find.text('Confirmar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'given secondary variant when built then renders an OutlinedButton',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          DbookButton(
            label: 'Cancelar',
            variant: DbookButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    },
  );

  testWidgets('given text variant when built then renders a TextButton', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DbookButton(
          label: 'Pular',
          variant: DbookButtonVariant.text,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byType(TextButton), findsOneWidget);
  });
}
