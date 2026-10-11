import 'package:dbook_admin_data/dbook_admin_data.dart';

/// A consulta de voos ↔ a *query string* da URL.
class FlightQueryCodec {
  const FlightQueryCodec._();

  static FlightQuery decode(Map<String, String> params) => (
    origin: params['origin'] ?? '',
    destination: params['destination'] ?? '',
    airline: params['airline'] ?? '',
    departureFrom: DateTime.tryParse(params['from'] ?? ''),
    departureTo: DateTime.tryParse(params['to'] ?? ''),
    status: switch (params['status']) {
      'scheduled' => FlightStatus.scheduled,
      'cancelled' => FlightStatus.cancelled,
      _ => null,
    },
    page: (int.tryParse(params['page'] ?? '') ?? 0).clamp(0, 1 << 20),
    size: (int.tryParse(params['size'] ?? '') ?? defaultFlightQuery.size).clamp(
      1,
      100,
    ),
  );

  static Map<String, String> encode(FlightQuery q) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      if (q.origin.isNotEmpty) 'origin': q.origin,
      if (q.destination.isNotEmpty) 'destination': q.destination,
      if (q.airline.isNotEmpty) 'airline': q.airline,
      if (q.departureFrom != null) 'from': day(q.departureFrom!),
      if (q.departureTo != null) 'to': day(q.departureTo!),
      if (q.status != null) 'status': q.status!.name,
      if (q.page != 0) 'page': '${q.page}',
      if (q.size != defaultFlightQuery.size) 'size': '${q.size}',
    };
  }
}

class FlightQueryEdit {
  const FlightQueryEdit._();

  static FlightQuery origin(FlightQuery q, String v) => (
    origin: v,
    destination: q.destination,
    airline: q.airline,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: q.status,
    page: 0,
    size: q.size,
  );

  static FlightQuery destination(FlightQuery q, String v) => (
    origin: q.origin,
    destination: v,
    airline: q.airline,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: q.status,
    page: 0,
    size: q.size,
  );

  static FlightQuery airline(FlightQuery q, String v) => (
    origin: q.origin,
    destination: q.destination,
    airline: v,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: q.status,
    page: 0,
    size: q.size,
  );

  static FlightQuery period(FlightQuery q, DateTime? from, DateTime? to) => (
    origin: q.origin,
    destination: q.destination,
    airline: q.airline,
    departureFrom: from,
    departureTo: to,
    status: q.status,
    page: 0,
    size: q.size,
  );

  static FlightQuery status(FlightQuery q, FlightStatus? v) => (
    origin: q.origin,
    destination: q.destination,
    airline: q.airline,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: v,
    page: 0,
    size: q.size,
  );

  static FlightQuery page(FlightQuery q, int v) => (
    origin: q.origin,
    destination: q.destination,
    airline: q.airline,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: q.status,
    page: v,
    size: q.size,
  );

  static FlightQuery size(FlightQuery q, int v) => (
    origin: q.origin,
    destination: q.destination,
    airline: q.airline,
    departureFrom: q.departureFrom,
    departureTo: q.departureTo,
    status: q.status,
    page: 0,
    size: v,
  );

  static FlightQuery cleared(FlightQuery q) => (
    origin: '',
    destination: '',
    airline: '',
    departureFrom: null,
    departureTo: null,
    status: null,
    page: 0,
    size: q.size,
  );
}
