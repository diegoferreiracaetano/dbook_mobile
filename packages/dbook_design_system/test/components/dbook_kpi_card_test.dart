import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: DbookTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 240, child: child)),
  ),
);

void main() {
  testWidgets('given a value and a delta when built then shows both with an '
      'arrow, not only a color', (tester) async {
    await tester.pumpWidget(
      _host(
        const DbookKpiCard(
          label: 'Receita',
          value: 'R\$ 12.480',
          delta: '+12,5%',
          trend: DbookTrend.up,
          trendIsGood: true,
        ),
      ),
    );

    expect(find.text('R\$ 12.480'), findsOneWidget);
    expect(find.text('+12,5%'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('given a rising bad metric when built then the delta uses the '
      'danger color', (tester) async {
    await tester.pumpWidget(
      _host(
        const DbookKpiCard(
          label: 'Cancelamentos',
          value: '42',
          delta: '+8%',
          trend: DbookTrend.up,
          trendIsGood: false,
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('+8%'));
    expect(text.style!.color, DbookStatusColors.light.danger);
  });

  testWidgets('given no value when built then shows a dash instead of a '
      'number', (tester) async {
    await tester.pumpWidget(_host(const DbookKpiCard(label: 'Reservas')));

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('given loading when built then shows skeletons and no value', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const DbookKpiCard(label: 'Receita', value: '1', isLoading: true)),
    );

    expect(find.byType(DbookSkeleton), findsWidgets);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('given an error and onRetry when retry is tapped then it '
      'retries', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      _host(
        DbookKpiCard(
          label: 'Receita',
          errorMessage: 'Servidor indisponível.',
          onRetry: () => retried++,
        ),
      ),
    );

    expect(find.text('Servidor indisponível.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    expect(retried, 1);
  });

  testWidgets('given a ready card when read by a screen reader then it is one '
      'sentence with label, value and delta', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const DbookKpiCard(
          label: 'Receita',
          value: 'R\$ 12.480',
          delta: '+12,5%',
          trend: DbookTrend.up,
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Receita, R\$ 12.480, +12,5%'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
