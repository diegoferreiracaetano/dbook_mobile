import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_providers.dart';
import 'dashboard_widgets.dart';

/// A evolução de uma métrica no tempo. O gráfico não é o único jeito de ler:
/// há um resumo em texto para o leitor de tela e "Ver como tabela" com os
/// mesmos pontos. A linha leva marcadores (forma) além da cor.
class SeriesCard extends ConsumerStatefulWidget {
  const SeriesCard({super.key, required this.period});

  final DashboardPeriod period;

  @override
  ConsumerState<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends ConsumerState<SeriesCard> {
  DashboardMetric _metric = DashboardMetric.revenue;
  DashboardGranularity _granularity = DashboardGranularity.day;
  bool _asTable = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = (
      metric: _metric,
      granularity: _granularity,
      period: widget.period,
    );
    final series = ref.watch(dashboardSeriesProvider(request));

    return DashboardSection(
      title: l10n.seriesTitle,
      actions: Wrap(
        spacing: DbookSpacing.md,
        runSpacing: DbookSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<DashboardMetric>(
            value: _metric,
            items: [
              for (final m in DashboardMetric.values)
                DropdownMenuItem(value: m, child: Text(metricLabel(l10n, m))),
            ],
            onChanged: (m) => setState(() => _metric = m ?? _metric),
          ),
          SegmentedButton<DashboardGranularity>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: DashboardGranularity.day,
                label: Text(l10n.granularityDay),
              ),
              ButtonSegment(
                value: DashboardGranularity.week,
                label: Text(l10n.granularityWeek),
              ),
            ],
            selected: {_granularity},
            onSelectionChanged: (s) => setState(() => _granularity = s.first),
          ),
          TextButton.icon(
            icon: Icon(
              _asTable ? Icons.show_chart : Icons.table_chart_outlined,
            ),
            label: Text(_asTable ? l10n.chartAsChart : l10n.chartAsTable),
            onPressed: () => setState(() => _asTable = !_asTable),
          ),
        ],
      ),
      child: SizedBox(
        height: 300,
        child: series.when(
          loading: () => const DbookLoadingIndicator(),
          error: (error, _) => DbookErrorState(
            message: portalErrorMessage(l10n, error),
            onRetry: () => ref.invalidate(dashboardSeriesProvider(request)),
          ),
          data: (timed) {
            final points = timed.value.points;
            if (points.isEmpty) {
              return DbookEmptyState(
                title: l10n.chartEmpty,
                message: l10n.tabEmptyHint,
              );
            }
            return _asTable
                ? _SeriesTable(metric: _metric, points: points)
                : _SeriesChart(metric: _metric, points: points);
          },
        ),
      ),
    );
  }
}

class _SeriesChart extends StatelessWidget {
  const _SeriesChart({required this.metric, required this.points});

  final DashboardMetric metric;
  final List<SeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final values = points.map((p) => p.value);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final total = values.fold<double>(0, (a, b) => a + b);
    final summary = l10n.chartSummary(
      metricLabel(l10n, metric),
      points.length,
      formatMetric(metric, min),
      formatMetric(metric, max),
      formatMetric(metric, total),
    );
    final interval = (points.length / 6).ceil().clamp(1, 1000).toDouble();
    final color = theme.colorScheme.primary;

    return Semantics(
      label: summary,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(
            right: DbookSpacing.md,
            top: DbookSpacing.sm,
          ),
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                  dashArray: const [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) => Text(
                      PortalFormats.compact(value),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      final d = points[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: DbookSpacing.xs),
                        child: Text(
                          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${PortalFormats.date(points[spot.x.round()].date)}\n'
                        '${formatMetric(metric, spot.y)}',
                        TextStyle(color: theme.colorScheme.onInverseSurface),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].value),
                  ],
                  color: color,
                  barWidth: 2.5,
                  isCurved: false,
                  dotData: FlDotData(
                    show: points.length <= 60,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: color,
                          strokeWidth: 1.5,
                          strokeColor: theme.colorScheme.surface,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeriesTable extends StatelessWidget {
  const _SeriesTable({required this.metric, required this.points});

  final DashboardMetric metric;
  final List<SeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DbookDataTable<SeriesPoint>(
      semanticLabel: metricLabel(l10n, metric),
      columns: [
        DbookColumn(
          id: 'date',
          label: l10n.chartColDate,
          width: 160,
          cellBuilder: (p) => Text(PortalFormats.date(p.date)),
        ),
        DbookColumn(
          id: 'value',
          label: l10n.chartColValue,
          width: 180,
          numeric: true,
          cellBuilder: (p) => Text(formatMetric(metric, p.value)),
        ),
      ],
      rows: points,
      rowKey: (p) => p.date,
    );
  }
}

/// As rotas mais vendidas, em ranking com barras proporcionais. O texto de
/// cada linha já diz tudo; a barra é só reforço visual.
class TopRoutesCard extends ConsumerWidget {
  const TopRoutesCard({super.key, required this.period});

  final DashboardPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final routes = ref.watch(dashboardTopRoutesProvider(period));

    return DashboardSection(
      title: l10n.topRoutesTitle,
      child: routes.when(
        loading: () => const SizedBox(
          height: DbookSizes.loadingMd,
          child: DbookLoadingIndicator(),
        ),
        error: (error, _) => SizedBox(
          height: 200,
          child: DbookErrorState(
            message: portalErrorMessage(l10n, error),
            onRetry: () => ref.invalidate(dashboardTopRoutesProvider(period)),
          ),
        ),
        data: (timed) {
          final items = timed.value;
          if (items.isEmpty) {
            return DbookEmptyState(
              title: l10n.topRoutesEmpty,
              message: l10n.tabEmptyHint,
            );
          }
          final top = items
              .map((r) => r.bookings)
              .reduce((a, b) => a > b ? a : b);
          return Column(
            children: [
              for (final route in items)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DbookSpacing.xs,
                  ),
                  child: Semantics(
                    label:
                        '${route.origin} → ${route.destination}: ${route.bookings} ${l10n.topRoutesColBookings}, '
                        '${PortalFormats.money(route.revenue)}',
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text('${route.origin} → ${route.destination}'),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    DbookRadius.xs,
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: top == 0
                                    ? 0
                                    : route.bookings / top,
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(
                                      DbookRadius.xs,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            '${route.bookings} · ${PortalFormats.money(route.revenue)}',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
