import 'package:dio/dio.dart';

import '../json.dart';
import '../models/catalog.dart';
import '../models/pages.dart';

/// Catálogo administrativo: voos, companhias, aeroportos e a importação em
/// lote (`/v1/admin/flights`, `airlines`, `airports`, `aircraft-models`).
abstract interface class CatalogApi {
  Future<PageOf<AdminFlight>> listFlights(FlightQuery query);

  Future<AdminFlightDetail> getFlight(int id);

  /// Devolve o id do voo criado.
  Future<int?> createFlight(FlightForm form);

  Future<AdminFlightDetail> updateFlight(
    int id,
    FlightForm form, {
    required int version,
  });

  Future<void> cancelFlight(int id);

  Future<ImportReport> importFlights(String csv, {required bool dryRun});

  Future<List<AircraftModel>> aircraftModels();

  Future<List<Airline>> airlines();

  Future<void> saveAirline({
    int? id,
    required String iataCode,
    required String name,
    String? logoUrl,
  });

  Future<void> deleteAirline(int id);

  Future<List<Airport>> airports();

  Future<void> saveAirport(Airport airport);

  Future<void> deleteAirport(int id);
}

class DioCatalogApi implements CatalogApi {
  const DioCatalogApi(this._dio);

  final Dio _dio;

  static String? _day(DateTime? d, {bool end = false}) => d == null
      ? null
      : FlightForm.localTime(
          end
              ? DateTime(d.year, d.month, d.day, 23, 59, 59)
              : DateTime(d.year, d.month, d.day),
        );

  @override
  Future<PageOf<AdminFlight>> listFlights(FlightQuery q) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/flights',
      queryParameters: compact({
        'origin': q.origin.trim().toUpperCase(),
        'destination': q.destination.trim().toUpperCase(),
        'airline': q.airline.trim().toUpperCase(),
        'departureFrom': _day(q.departureFrom),
        'departureTo': _day(q.departureTo, end: true),
        'status': q.status == null ? null : flightStatusToWire(q.status!),
        'page': q.page,
        'size': q.size,
      }),
    );
    return PageOf.fromJson(bodyOf(response), AdminFlight.fromJson);
  });

  @override
  Future<AdminFlightDetail> getFlight(int id) => guarded(() async {
    final response = await _dio.get<Object>('/admin/flights/$id');
    return AdminFlightDetail.fromJson(bodyOf(response));
  });

  @override
  Future<int?> createFlight(FlightForm form) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/flights',
      data: form.toJson(),
    );
    return bodyOf(response).integer('id');
  });

  @override
  Future<AdminFlightDetail> updateFlight(
    int id,
    FlightForm form, {
    required int version,
  }) => guarded(() async {
    final response = await _dio.put<Object>(
      '/admin/flights/$id',
      data: {...form.toJson(), 'version': version},
    );
    return AdminFlightDetail.fromJson(bodyOf(response));
  });

  @override
  Future<void> cancelFlight(int id) =>
      guarded(() async => _dio.post<Object>('/admin/flights/$id/cancel'));

  @override
  Future<ImportReport> importFlights(String csv, {required bool dryRun}) =>
      guarded(() async {
        final response = await _dio.post<Object>(
          '/admin/flights/import',
          queryParameters: {'dryRun': dryRun},
          data: csv,
          options: Options(
            contentType: 'text/csv',
            // 422 traz o relatório com os erros por linha: não é falha de rede
            validateStatus: (status) =>
                status != null && (status < 300 || status == 422),
          ),
        );
        return ImportReport.fromJson(bodyOf(response));
      });

  @override
  Future<List<AircraftModel>> aircraftModels() =>
      _list('/admin/aircraft-models', AircraftModel.fromJson);

  @override
  Future<List<Airline>> airlines() =>
      _list('/admin/airlines', Airline.fromJson);

  @override
  Future<void> saveAirline({
    int? id,
    required String iataCode,
    required String name,
    String? logoUrl,
  }) => guarded(() async {
    final data = {
      'iataCode': iataCode.trim().toUpperCase(),
      'name': name.trim(),
      // vazio limpa o logo no servidor
      'logoUrl': (logoUrl ?? '').trim(),
    };
    if (id == null) {
      await _dio.post<Object>('/admin/airlines', data: data);
    } else {
      await _dio.put<Object>('/admin/airlines/$id', data: data);
    }
  });

  @override
  Future<void> deleteAirline(int id) =>
      guarded(() async => _dio.delete<Object>('/admin/airlines/$id'));

  @override
  Future<List<Airport>> airports() =>
      _list('/admin/airports', Airport.fromJson);

  @override
  Future<void> saveAirport(Airport airport) => guarded(() async {
    if (airport.id == null) {
      await _dio.post<Object>('/admin/airports', data: airport.toJson());
    } else {
      await _dio.put<Object>(
        '/admin/airports/${airport.id}',
        data: airport.toJson(),
      );
    }
  });

  @override
  Future<void> deleteAirport(int id) =>
      guarded(() async => _dio.delete<Object>('/admin/airports/$id'));

  Future<List<T>> _list<T>(String path, T Function(Json) parse) =>
      guarded(() async {
        final response = await _dio.get<Object>(path);
        final data = response.data;
        if (data is! List) return const [];
        return [
          for (final item in data)
            if (item is Map<String, dynamic>) parse(item),
        ];
      });
}
