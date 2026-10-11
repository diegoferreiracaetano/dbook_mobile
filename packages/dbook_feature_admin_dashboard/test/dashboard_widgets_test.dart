import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_admin_dashboard/src/dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await PortalFormats.init();
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test(
    'given the revenue metric when formatting then it is money in reais',
    () {
      final text = formatMetric(
        DashboardMetric.revenue,
        1234.5,
      ).replaceAll('\u00A0', ' ');

      expect(text, r'R$ 1.234,50');
    },
  );

  test('given a count metric when formatting then it is a rounded integer', () {
    expect(formatMetric(DashboardMetric.bookings, 41.6), '42');
  });

  test('given each metric when asking its label then it is the translated '
      'one', () {
    expect(
      metricLabel(l10n, DashboardMetric.revenue),
      isNot(equals(metricLabel(l10n, DashboardMetric.bookings))),
    );
  });

  test('given a period when asking the previous one then it has the same '
      'length right before', () {
    final period = (from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 10));

    final previous = previousPeriod(period);

    expect(previous.to, DateTime(2026, 9, 30));
    expect(
      previous.to.difference(previous.from).inDays,
      period.to.difference(period.from).inDays,
    );
  });

  testWidgets('given a title and content when built then shows both', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(
          body: DashboardSection(title: 'Receita', child: Text('R\$ 10')),
        ),
      ),
    );

    expect(find.text('Receita'), findsOneWidget);
    expect(find.text('R\$ 10'), findsOneWidget);
  });
}
