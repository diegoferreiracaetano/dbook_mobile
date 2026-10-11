import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

DioException _error(
  int status,
  Object? body, {
  Map<String, List<String>>? headers,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: body,
      headers: Headers.fromMap(headers ?? {}),
    ),
  );
}

void main() {
  test('given an error body with a code when mapped then the exception '
      'carries the code', () {
    final exception = mapDioException(
      _error(409, {'error': 'mudou', 'code': 'STALE_VERSION'}),
    );

    expect(exception, isA<DbookConflictException>());
    expect(exception.code, 'STALE_VERSION');
    expect(exception.message, 'mudou');
  });

  test('given a 429 with Retry-After when mapped then the seconds are '
      'kept', () {
    final exception = mapDioException(
      _error(
        429,
        {'error': 'calma', 'code': 'TOO_MANY_ATTEMPTS'},
        headers: {
          'retry-after': ['42'],
        },
      ),
    );

    expect(exception, isA<DbookRateLimitException>());
    expect(exception.retryAfter, 42);
    expect(exception.code, 'TOO_MANY_ATTEMPTS');
  });

  test('given a 422 when mapped then it is unprocessable, not unknown', () {
    final exception = mapDioException(
      _error(422, {'error': 'x', 'code': 'PROMO_REJECTED'}),
    );

    expect(exception, isA<DbookUnprocessableException>());
    expect(exception.code, 'PROMO_REJECTED');
  });

  test('given a body without a code when mapped then the code is null', () {
    final exception = mapDioException(_error(404, {'error': 'nada'}));

    expect(exception.code, isNull);
  });
}
