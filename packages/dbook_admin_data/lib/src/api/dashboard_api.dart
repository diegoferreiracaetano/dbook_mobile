import 'package:dio/dio.dart';

import '../json.dart';
import '../models/dashboard.dart';

/// Os números do painel (`/v1/admin/dashboard/*`, permissão `DASHBOARD_READ`).
/// O servidor guarda cada resposta em cache por 60 segundos.
abstract interface class DashboardApi {
  Future<DashboardSummary> summary(DashboardPeriod period);

  Future<TimeSeries> timeSeries({
    required DashboardMetric metric,
    required DashboardGranularity granularity,
    required DashboardPeriod period,
  });

  Future<List<TopRoute>> topRoutes(DashboardPeriod period, {int limit = 10});
}

class DioDashboardApi implements DashboardApi {
  const DioDashboardApi(this._dio);

  final Dio _dio;

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, String> _range(DashboardPeriod p) => {
    'from': _day(p.from),
    'to': _day(p.to),
  };

  @override
  Future<DashboardSummary> summary(DashboardPeriod period) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/dashboard/summary',
      queryParameters: _range(period),
    );
    return DashboardSummary.fromJson(bodyOf(response));
  });

  @override
  Future<TimeSeries> timeSeries({
    required DashboardMetric metric,
    required DashboardGranularity granularity,
    required DashboardPeriod period,
  }) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/dashboard/timeseries',
      queryParameters: {
        'metric': dashboardMetricToWire(metric),
        'granularity': dashboardGranularityToWire(granularity),
        ..._range(period),
      },
    );
    return TimeSeries.fromJson(bodyOf(response));
  });

  @override
  Future<List<TopRoute>> topRoutes(DashboardPeriod period, {int limit = 10}) =>
      guarded(() async {
        final response = await _dio.get<Object>(
          '/admin/dashboard/top-routes',
          queryParameters: {'limit': limit, ..._range(period)},
        );
        return bodyOf(response).list('routes', TopRoute.fromJson);
      });
}
