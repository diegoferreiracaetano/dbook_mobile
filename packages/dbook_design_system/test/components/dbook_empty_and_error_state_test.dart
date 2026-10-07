import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('given an empty state with an action when the action is tapped '
      'then it fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        DbookEmptyState(
          title: 'Nenhum cliente',
          message: 'Tente outro filtro.',
          actionLabel: 'Limpar filtros',
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Nenhum cliente'), findsOneWidget);
    await tester.tap(find.text('Limpar filtros'));
    expect(tapped, isTrue);
  });

  testWidgets('given an error state with onRetry when "Tentar de novo" is '
      'tapped then it retries', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      _host(
        DbookErrorState(
          message: 'Servidor indisponível.',
          onRetry: () => retried++,
        ),
      ),
    );

    expect(find.text('Servidor indisponível.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    expect(retried, 1);
  });

  testWidgets('given an error state without onRetry when built then shows no '
      'retry button', (tester) async {
    await tester.pumpWidget(
      _host(const DbookErrorState(message: 'Sem permissão.')),
    );

    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('given an error state when built then it is a live region for '
      'screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const DbookErrorState(message: 'Falhou.')));

    expect(
      tester.getSemantics(find.byType(DbookErrorState)),
      matchesSemantics(isLiveRegion: true, hasEnabledState: false),
    );
    handle.dispose();
  });
}
