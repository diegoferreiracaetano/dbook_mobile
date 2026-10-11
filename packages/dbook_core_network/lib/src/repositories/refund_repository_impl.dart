import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';
import '../wire_enums.dart';

class RefundRepositoryImpl implements RefundRepository {
  const RefundRepositoryImpl(this._dio);

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

  @override
  Future<CancellationPolicy> policy(int bookingId) => _guard(() async {
    final response = await _dio.get<Object>(
      '/bookings/$bookingId/cancellation-policy',
    );
    final body = _body(response);
    return CancellationPolicy(
      bookingId: body.count('bookingId'),
      action: cancellationActionFromWire(body.text('action')),
      refundAmount: body.decimal('refundAmount'),
      refundableUntil: body.time('refundableUntil'),
      blockedBy: body.str('blockedBy') == null
          ? null
          : cancellationBlockFromWire(body.text('blockedBy')),
    );
  });

  @override
  Future<RefundRequestResult> request(
    int bookingId, {
    required String idempotencyKey,
  }) => _guard(() async {
    final response = await _dio.post<Object>(
      '/bookings/$bookingId/refund-request',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    final body = _body(response);
    return RefundRequestResult(
      bookingId: body.count('bookingId'),
      amount: body.decimal('amount') ?? 0,
      status: refundProgressFromWire(body.text('status')),
    );
  });
}
