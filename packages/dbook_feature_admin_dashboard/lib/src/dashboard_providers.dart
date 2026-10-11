import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardApiProvider = Provider<DashboardApi>(
  (ref) => DioDashboardApi(ref.watch(adminDioProvider)),
);

/// Bate a cada 60 s (o prazo do cache do servidor): quem a observa busca de
/// novo e, enquanto isso, mantém o número anterior na tela.
final dashboardTickProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream.periodic(const Duration(seconds: 60), (i) => i),
);

/// Bate a cada 15 s só para o "atualizado há…" se manter correto.
final dashboardClockProvider = StreamProvider.autoDispose<DateTime>((
  ref,
) async* {
  final now = ref.watch(adminClockProvider);
  yield now();
  yield* Stream.periodic(const Duration(seconds: 15), (_) => now());
});

final dashboardSummaryProvider = FutureProvider.autoDispose
    .family<Timed<DashboardSummary>, DashboardPeriod>((ref, period) async {
      ref.watch(dashboardTickProvider);
      final value = await ref.watch(dashboardApiProvider).summary(period);
      return Timed(value, ref.read(adminClockProvider)());
    });

/// O período anterior, para a variação dos cartões. Se ele falha, só a
/// variação some; o número do período continua.
final dashboardPreviousSummaryProvider = FutureProvider.autoDispose
    .family<DashboardSummary, DashboardPeriod>((ref, period) {
      ref.watch(dashboardTickProvider);
      return ref.watch(dashboardApiProvider).summary(previousPeriod(period));
    });

typedef SeriesRequest = ({
  DashboardMetric metric,
  DashboardGranularity granularity,
  DashboardPeriod period,
});

final dashboardSeriesProvider = FutureProvider.autoDispose
    .family<Timed<TimeSeries>, SeriesRequest>((ref, request) async {
      ref.watch(dashboardTickProvider);
      final value = await ref
          .watch(dashboardApiProvider)
          .timeSeries(
            metric: request.metric,
            granularity: request.granularity,
            period: request.period,
          );
      return Timed(value, ref.read(adminClockProvider)());
    });

final dashboardTopRoutesProvider = FutureProvider.autoDispose
    .family<Timed<List<TopRoute>>, DashboardPeriod>((ref, period) async {
      ref.watch(dashboardTickProvider);
      final value = await ref.watch(dashboardApiProvider).topRoutes(period);
      return Timed(value, ref.read(adminClockProvider)());
    });
