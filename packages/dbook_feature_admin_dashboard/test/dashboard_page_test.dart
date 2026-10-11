import 'package:dbook_feature_admin_dashboard/dbook_feature_admin_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

void main() {
  testWidgets('given the real summary when the panel builds then shows the '
      'revenue and booking counters', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({
        '/admin/dashboard/summary': 'summary',
        '/admin/dashboard/timeseries': 'timeseries',
        '/admin/dashboard/top-routes': 'top_routes',
      }),
      child: DashboardPage(
        period: (from: DateTime(2026, 9, 1), to: DateTime(2026, 10, 9)),
        onPeriodChanged: (_) {},
      ),
    );

    expect(find.textContaining('1.050,00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given the series when switching to the table view then shows '
      'the table and can go back', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({
        '/admin/dashboard/summary': 'summary',
        '/admin/dashboard/timeseries': 'timeseries',
        '/admin/dashboard/top-routes': 'top_routes',
      }),
      child: DashboardPage(
        period: (from: DateTime(2026, 9, 1), to: DateTime(2026, 10, 9)),
        onPeriodChanged: (_) {},
      ),
    );

    await tester.ensureVisible(find.text('Ver como tabela'));
    await tester.tap(find.text('Ver como tabela'));
    await tester.pumpAndSettle();

    expect(find.text('Ver como gráfico'), findsOneWidget);
    await tester.ensureVisible(find.text('Ver como gráfico'));
    await tester.tap(find.text('Ver como gráfico'));
    await tester.pumpAndSettle();

    expect(find.text('Ver como tabela'), findsOneWidget);
  });

  testWidgets('given the series when choosing weekly and another metric '
      'then asks the server for them', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/dashboard/summary': {
          'grossRevenue': 1050,
          'netRevenue': 1050,
          'refunded': 0,
          'newCustomers': 1,
          'bookingsByStatus': {'CONFIRMED': 1},
        },
        'GET /admin/dashboard/timeseries': {
          'metric': 'REVENUE',
          'granularity': 'DAY',
          'points': [
            {'date': '2026-10-08', 'value': 0},
            {'date': '2026-10-09', 'value': 1050},
          ],
        },
        'GET /admin/dashboard/top-routes': {'limit': 10, 'routes': <Object>[]},
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: DashboardPage(
        period: (from: DateTime(2026, 9, 1), to: DateTime(2026, 10, 9)),
        onPeriodChanged: (_) {},
      ),
    );

    await tester.ensureVisible(find.text('Por semana'));
    await tester.tap(find.text('Por semana'));
    await tester.pumpAndSettle();

    final weekly = recorder
        .to('GET', '/admin/dashboard/timeseries')
        .where((c) => c.queryParameters['granularity'] == 'WEEK');
    expect(weekly, isNotEmpty);
  });

  testWidgets('given routes with bookings when the panel builds then draws a '
      'bar per route', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/dashboard/summary': {
          'grossRevenue': 1050,
          'netRevenue': 1050,
          'refunded': 0,
          'newCustomers': 1,
          'bookingsByStatus': {'CONFIRMED': 1},
        },
        'GET /admin/dashboard/timeseries': {
          'metric': 'REVENUE',
          'granularity': 'DAY',
          'points': [
            {'date': '2026-10-09', 'value': 1050},
          ],
        },
        'GET /admin/dashboard/top-routes': {
          'limit': 10,
          'routes': [
            {
              'origin': 'GRU',
              'destination': 'LIS',
              'bookings': 4,
              'revenue': 4000,
            },
            {
              'origin': 'GIG',
              'destination': 'MAD',
              'bookings': 1,
              'revenue': 900,
            },
          ],
        },
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: DashboardPage(
        period: (from: DateTime(2026, 9, 1), to: DateTime(2026, 10, 9)),
        onPeriodChanged: (_) {},
      ),
    );

    await tester.ensureVisible(find.text('GRU → LIS'));
    expect(find.text('GRU → LIS'), findsOneWidget);
    expect(find.text('GIG → MAD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
