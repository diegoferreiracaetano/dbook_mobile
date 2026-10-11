import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_providers.dart';
import 'dashboard_series.dart';

/// O painel de negócio. Cada bloco busca por conta própria: um que falha
/// mostra o seu erro com "Tentar de novo" e os outros seguem de pé. Atualiza
/// sozinho a cada 60 s e diz há quanto tempo.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.period,
    required this.onPeriodChanged,
  });

  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = ref.watch(dashboardSummaryProvider(period));
    final now = ref.watch(dashboardClockProvider).value ?? DateTime.now();
    final today = ref.watch(adminClockProvider)();

    final updated = summary.value == null
        ? null
        : l10n.dashboardUpdated(
            summary.value!.fetchedAt.isAfter(
                  now.subtract(const Duration(seconds: 60)),
                )
                ? l10n.dashboardNow
                : PortalFormats.ago(summary.value!.fetchedAt, now),
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (updated != null)
                Padding(
                  padding: const EdgeInsets.only(right: DbookSpacing.sm),
                  child: Text(updated, style: theme.textTheme.bodySmall),
                ),
              IconButton(
                tooltip: l10n.dashboardRefresh,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(dashboardSummaryProvider(period));
                  ref.invalidate(dashboardPreviousSummaryProvider(period));
                },
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookFilterBar(
            onClearAll: () => onPeriodChanged(lastDays(today, 30)),
            period: DateTimeRange(start: period.from, end: period.to),
            onPeriodChanged: (range) => onPeriodChanged(
              range == null
                  ? lastDays(today, 30)
                  : (from: range.start, to: range.end),
            ),
            today: () => today,
          ),
          const SizedBox(height: DbookSpacing.lg),
          _KpiGrid(period: period),
          const SizedBox(height: DbookSpacing.xl),
          SeriesCard(period: period),
          const SizedBox(height: DbookSpacing.xl),
          TopRoutesCard(period: period),
        ],
      ),
    );
  }
}

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid({required this.period});

  final DashboardPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(dashboardSummaryProvider(period));
    final previous = ref.watch(dashboardPreviousSummaryProvider(period)).value;
    final summary = current.value?.value;
    final loading = current.isLoading && !current.hasValue;
    final error = current.hasError && !current.hasValue
        ? portalErrorMessage(l10n, current.error!)
        : null;
    void retry() => ref.invalidate(dashboardSummaryProvider(period));

    DbookKpiCard money(
      String label,
      String info,
      double? value,
      double? before,
    ) => _card(
      label: label,
      info: info,
      value: value == null ? null : PortalFormats.money(value),
      change: value == null ? null : variation(value, before),
      loading: loading,
      error: error,
      onRetry: retry,
    );

    DbookKpiCard count(String label, String info, int? value, int? before) =>
        _card(
          label: label,
          info: info,
          value: value == null ? null : PortalFormats.integer(value),
          change: value == null ? null : variation(value, before),
          loading: loading,
          error: error,
          onRetry: retry,
        );

    DbookKpiCard rate(String label, String info, double? value) => _card(
      label: label,
      info: info,
      value: summary == null
          ? null
          : (value == null
                ? l10n.kpiNotApplicable
                : PortalFormats.percent(value)),
      loading: loading,
      error: error,
      onRetry: retry,
    );

    final cards = <Widget>[
      money(
        l10n.kpiNetRevenue,
        l10n.glossNetRevenue,
        summary?.netRevenue,
        previous?.netRevenue,
      ),
      money(
        l10n.kpiGrossRevenue,
        l10n.glossGrossRevenue,
        summary?.grossRevenue,
        previous?.grossRevenue,
      ),
      money(
        l10n.kpiRefunded,
        l10n.glossRefunded,
        summary?.refunded,
        previous?.refunded,
      ),
      count(
        l10n.kpiCreatedBookings,
        l10n.glossBookings,
        summary?.totalBookings,
        previous?.totalBookings,
      ),
      count(
        l10n.kpiNewCustomers,
        l10n.glossNewCustomers,
        summary?.newCustomers,
        previous?.newCustomers,
      ),
      rate(l10n.kpiConversion, l10n.glossConversion, summary?.conversionRate),
      rate(l10n.kpiExpiration, l10n.glossExpiration, summary?.expirationRate),
      rate(l10n.kpiOccupancy, l10n.glossOccupancy, summary?.averageOccupancy),
    ];

    // Cada cartão tem largura própria: em tela larga viram uma grade, em
    // tela estreita empilham (o `Wrap` quebra sozinho).
    return Wrap(
      spacing: DbookSpacing.md,
      runSpacing: DbookSpacing.md,
      children: [
        for (final card in cards)
          SizedBox(width: DbookSizes.kpiCard, child: card),
      ],
    );
  }

  DbookKpiCard _card({
    required String label,
    required String info,
    required String? value,
    required bool loading,
    required String? error,
    required VoidCallback onRetry,
    double? change,
  }) {
    return DbookKpiCard(
      label: label,
      info: info,
      value: value,
      isLoading: loading,
      errorMessage: error,
      onRetry: onRetry,
      delta: change == null ? null : PortalFormats.signedPercent(change),
      trend: change == null
          ? DbookTrend.flat
          : (change > 0
                ? DbookTrend.up
                : (change < 0 ? DbookTrend.down : DbookTrend.flat)),
    );
  }
}
