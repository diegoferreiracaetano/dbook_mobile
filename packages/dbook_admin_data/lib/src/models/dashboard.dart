import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_core_network/dbook_core_network.dart';

import '../json.dart';

/// Um período de datas, os dois dias incluídos, no fuso de São Paulo (o
/// servidor é quem conta). É a chave dos providers do painel e vai na URL.
typedef DashboardPeriod = ({DateTime from, DateTime to});

/// O mesmo número de dias imediatamente antes de [period]: a base da
/// variação mostrada nos cartões.
DashboardPeriod previousPeriod(DashboardPeriod period) {
  final days = period.to.difference(period.from).inDays + 1;
  return (
    from: period.from.subtract(Duration(days: days)),
    to: period.from.subtract(const Duration(days: 1)),
  );
}

/// Os últimos [days] dias até [today], como o servidor assume sem parâmetros.
DashboardPeriod lastDays(DateTime today, int days) {
  final end = DateTime(today.year, today.month, today.day);
  return (from: end.subtract(Duration(days: days - 1)), to: end);
}

class DashboardSummary {
  const DashboardSummary({
    required this.bookingsByStatus,
    required this.grossRevenue,
    required this.refunded,
    required this.netRevenue,
    required this.newCustomers,
    this.conversionRate,
    this.expirationRate,
    this.averageOccupancy,
  });

  factory DashboardSummary.fromJson(Json json) {
    final byStatus = <BookingStatus, int>{};
    final raw = json.obj('bookingsByStatus') ?? const {};
    for (final entry in raw.entries) {
      final count = entry.value;
      if (count is num) {
        byStatus.update(
          bookingStatusFromWire(entry.key),
          (value) => value + count.toInt(),
          ifAbsent: () => count.toInt(),
        );
      }
    }
    return DashboardSummary(
      bookingsByStatus: byStatus,
      grossRevenue: json.decimal('grossRevenue') ?? 0,
      refunded: json.decimal('refunded') ?? 0,
      netRevenue: json.decimal('netRevenue') ?? 0,
      newCustomers: json.count('newCustomers'),
      conversionRate: json.decimal('conversionRate'),
      expirationRate: json.decimal('expirationRate'),
      averageOccupancy: json.decimal('averageOccupancy'),
    );
  }

  final Map<BookingStatus, int> bookingsByStatus;
  final double grossRevenue;
  final double refunded;
  final double netRevenue;
  final int newCustomers;

  /// De 0 a 1; `null` quando não há o que dividir (período sem reservas).
  final double? conversionRate;
  final double? expirationRate;
  final double? averageOccupancy;

  int get totalBookings => bookingsByStatus.values.fold(0, (a, b) => a + b);
}

/// A variação de [current] sobre [previous]: `null` quando não dá para
/// comparar (sem base, ou base zero).
double? variation(num current, num? previous) {
  if (previous == null || previous == 0) return null;
  return (current - previous) / previous;
}

enum DashboardMetric { revenue, bookings, newCustomers }

String dashboardMetricToWire(DashboardMetric metric) => switch (metric) {
  DashboardMetric.revenue => 'REVENUE',
  DashboardMetric.bookings => 'BOOKINGS',
  DashboardMetric.newCustomers => 'NEW_CUSTOMERS',
};

enum DashboardGranularity { day, week }

String dashboardGranularityToWire(DashboardGranularity g) =>
    g == DashboardGranularity.day ? 'DAY' : 'WEEK';

class SeriesPoint {
  const SeriesPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

class TimeSeries {
  const TimeSeries({required this.points});

  factory TimeSeries.fromJson(Json json) => TimeSeries(
    points: [
      for (final p in json.list('points', (j) => j))
        if (DateTime.tryParse(p.text('date')) != null)
          SeriesPoint(DateTime.parse(p.text('date')), p.decimal('value') ?? 0),
    ],
  );

  final List<SeriesPoint> points;
}

class TopRoute {
  const TopRoute({
    required this.origin,
    required this.destination,
    required this.bookings,
    required this.revenue,
  });

  factory TopRoute.fromJson(Json json) => TopRoute(
    origin: json.text('origin'),
    destination: json.text('destination'),
    bookings: json.count('bookings'),
    revenue: json.decimal('revenue') ?? 0,
  );

  final String origin;
  final String destination;
  final int bookings;
  final double revenue;
}

/// Um valor e o instante em que foi buscado ("atualizado há 2 min").
class Timed<T> {
  const Timed(this.value, this.fetchedAt);

  final T value;
  final DateTime fetchedAt;
}
