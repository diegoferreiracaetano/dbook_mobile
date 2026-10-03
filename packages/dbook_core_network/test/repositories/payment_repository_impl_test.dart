import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _CapturingInterceptor extends Interceptor {
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    handler.resolve(
      Response(
        requestOptions: options,
        data: {
          'id': 55,
          'amount': 800.0,
          'cardLast4': '4242',
          'bookingIds': [1, 2],
          'status': 'CONFIRMED',
        },
      ),
    );
  }
}

void main() {
  test('given an idempotency key when paying then sends it in the '
      'Idempotency-Key header', () async {
    final interceptor = _CapturingInterceptor();
    final repository = PaymentRepositoryImpl(
      Dio()..interceptors.add(interceptor),
    );

    final payment = await repository.pay(
      bookingIds: [1, 2],
      cardLast4: '4242',
      cardholderName: 'Jane Doe',
      idempotencyKey: 'key-1',
    );

    expect(interceptor.captured!.path, '/payments');
    expect(interceptor.captured!.headers['Idempotency-Key'], 'key-1');
    expect(payment.id, 55);
  });
}
