import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class PriceRepositoryImpl implements PriceRepository {
  const PriceRepositoryImpl(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static Json _body(Response<Object> response) =>
      response.data is Map<String, dynamic>
      ? response.data! as Json
      : <String, dynamic>{};

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static PriceAlert _alert(Json json) => PriceAlert(
    id: json.count('id'),
    origin: json.text('origin'),
    destination: json.text('destination'),
    date:
        DateTime.tryParse(json.text('date')) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    targetPrice: json.decimal('targetPrice') ?? 0,
    active: json.flag('active', fallback: true),
    lastNotifiedAt: json.time('lastNotifiedAt'),
  );

  @override
  Future<PriceHistory> history(int flightId) => _guard(() async {
    final response = await _dio.get<Object>('/flights/$flightId/price-history');
    final body = _body(response);
    return PriceHistory(
      flightId: body.count('flightId'),
      current: body.decimal('current') ?? 0,
      lowest: body.decimal('lowest') ?? 0,
      highest: body.decimal('highest') ?? 0,
      points: [
        for (final p in body.list('points', (j) => j))
          if (p.time('changedAt') != null)
            PricePoint(
              price: p.decimal('price') ?? 0,
              changedAt: p.time('changedAt')!,
            ),
      ],
    );
  });

  @override
  Future<List<PriceAlert>> alerts() => _guard(() async {
    final response = await _dio.get<Object>(
      '/price-alerts',
      queryParameters: {'page': 0, 'size': 100},
    );
    final data = response.data;
    if (data is List) {
      return [
        for (final item in data)
          if (item is Map<String, dynamic>) _alert(item),
      ];
    }
    return _body(response).list('items', _alert);
  });

  @override
  Future<PriceAlert> createAlert({
    required String origin,
    required String destination,
    required DateTime date,
    required double targetPrice,
  }) => _guard(() async {
    final response = await _dio.post<Object>(
      '/price-alerts',
      data: {
        'origin': origin,
        'destination': destination,
        'date': _day(date),
        'targetPrice': targetPrice,
      },
    );
    return _alert(_body(response));
  });

  @override
  Future<PriceAlert> updateAlert(int id, {double? targetPrice, bool? active}) =>
      _guard(() async {
        final response = await _dio.patch<Object>(
          '/price-alerts/$id',
          data: {'targetPrice': ?targetPrice, 'active': ?active},
        );
        return _alert(_body(response));
      });

  @override
  Future<void> deleteAlert(int id) =>
      _guard(() async => _dio.delete<Object>('/price-alerts/$id'));
}
