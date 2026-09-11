import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  DioException buildError({required int statusCode, Object? data}) {
    final requestOptions = RequestOptions(path: '/bookings');
    return DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  final cases = <(int, Type)>[
    (400, DbookValidationException),
    (401, DbookUnauthorizedException),
    (403, DbookForbiddenException),
    (404, DbookNotFoundException),
    (409, DbookConflictException),
    (429, DbookRateLimitException),
    (502, DbookBadGatewayException),
    (503, DbookServiceUnavailableException),
    (500, DbookUnknownNetworkException),
  ];

  for (final (statusCode, expectedType) in cases) {
    test(
      'given a $statusCode response when mapped then returns $expectedType',
      () {
        final exception = mapDioException(buildError(statusCode: statusCode));
        expect(exception.runtimeType, expectedType);
      },
    );
  }

  test(
    'given a body with an error message when mapped then the message is used',
    () {
      final exception = mapDioException(
        buildError(statusCode: 403, data: {'error': 'Not the booking owner'}),
      );

      expect(exception.message, 'Not the booking owner');
    },
  );
}
