import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Curto-circuita toda requisição do [Dio] de teste com uma resposta
/// enlatada, sem tocar a rede de verdade.
class _FakeResponseInterceptor extends Interceptor {
  _FakeResponseInterceptor({this.data, this.statusCode = 200, this.error});

  final Object? data;
  final int statusCode;
  final DioException? error;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (error != null) {
      handler.reject(error!);
      return;
    }

    handler.resolve(
      Response(requestOptions: options, statusCode: statusCode, data: data),
    );
  }
}

Dio _dioReturning({Object? data, int statusCode = 200, DioException? error}) {
  return Dio()
    ..interceptors.add(
      _FakeResponseInterceptor(
        data: data,
        statusCode: statusCode,
        error: error,
      ),
    );
}

void main() {
  test(
    'given a successful search response when called then maps every flight',
    () async {
      final dio = _dioReturning(
        data: [
          {
            'id': 1,
            'flightNumber': 'IB 6821',
            'origin': 'GRU',
            'destination': 'MAD',
            'departureTime': '2026-01-13T10:30:00',
            'arrivalTime': '2026-01-14T06:45:00',
            'seatClass': 'ECONOMY',
            'price': 450.0,
            'availableCapacity': 42,
          },
        ],
      );
      final repository = FlightRepositoryImpl(dio);

      final flights = await repository.search(
        originIataCode: 'GRU',
        destinationIataCode: 'MAD',
        date: DateTime(2026, 1, 13),
      );

      expect(flights, hasLength(1));
      expect(flights.single.flightNumber, 'IB 6821');
      expect(flights.single.seatClass, SeatClass.economy);
    },
  );

  test(
    'given a 404 response when searching then throws DbookNotFoundException',
    () async {
      final requestOptions = RequestOptions(path: '/flights/search');
      final dio = _dioReturning(
        error: DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 404,
            data: {'error': 'Not found'},
          ),
        ),
      );
      final repository = FlightRepositoryImpl(dio);

      expect(
        () => repository.search(
          originIataCode: 'GRU',
          destinationIataCode: 'MAD',
          date: DateTime(2026, 1, 13),
        ),
        throwsA(isA<DbookNotFoundException>()),
      );
    },
  );
}
