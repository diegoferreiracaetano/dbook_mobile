import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({Widget? footer}) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () => showDbookSidePanel<void>(
            context: context,
            title: 'Diego Ferreira',
            bodyBuilder: (_) => const Text('Ficha do cliente'),
            footer: footer,
          ),
          child: const Text('Abrir'),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('given the opener when tapped then the panel shows title and '
      'body', (tester) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    expect(find.text('Diego Ferreira'), findsOneWidget);
    expect(find.text('Ficha do cliente'), findsOneWidget);
  });

  testWidgets('given an open panel when Esc is pressed then it closes', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Ficha do cliente'), findsNothing);
  });

  testWidgets('given an open panel when the close button is tapped then it '
      'closes', (tester) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    await tester.tap(find.byTooltip('Fechar painel'));
    await tester.pumpAndSettle();

    expect(find.text('Ficha do cliente'), findsNothing);
  });

  testWidgets('given an open panel when tapping outside then it closes', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    await tester.tapAt(const Offset(10, 300));
    await tester.pumpAndSettle();

    expect(find.text('Ficha do cliente'), findsNothing);
  });

  testWidgets('given an open panel when Tab is pressed many times then the '
      'focus never leaves the panel', (tester) async {
    await tester.pumpWidget(
      _app(footer: const TextButton(onPressed: null, child: Text('Salvar'))),
    );
    await _open(tester);

    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.ancestor(
          of: find.byWidget(focused.widget),
          matching: find.text('Abrir'),
        ),
        findsNothing,
      );
      expect(
        focused.findAncestorWidgetOfExactType<ElevatedButton>(),
        isNull,
        reason: 'focus escaped to the opener behind the panel',
      );
    }
  });

  testWidgets('given the panel closes when it was opened by keyboard then '
      'the focus returns to the opener', (tester) async {
    await tester.pumpWidget(_app());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Ficha do cliente'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    final focused = FocusManager.instance.primaryFocus!.context!;
    expect(focused.findAncestorWidgetOfExactType<ElevatedButton>(), isNotNull);
  });

  testWidgets('given a narrow screen when opened then the panel takes the '
      'whole width', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await _open(tester);

    final widths = tester
        .widgetList(
          find.ancestor(
            of: find.text('Diego Ferreira'),
            matching: find.byType(Material),
          ),
        )
        .map((m) => tester.getSize(find.byWidget(m)).width);
    expect(widths.reduce((a, b) => a > b ? a : b), 400);
  });

  testWidgets('given an open panel when read by a screen reader then it is '
      'named after its title', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await _open(tester);

    expect(find.bySemanticsLabel('Diego Ferreira'), findsWidgets);
    handle.dispose();
  });
}
