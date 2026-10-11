import 'package:dio/dio.dart';

import '../json.dart';
import '../models/bookings.dart';
import '../models/pages.dart';

/// Reservas e reembolsos do ponto de vista da equipe (`/v1/admin/bookings`,
/// `/v1/admin/refunds`).
abstract interface class AdminBookingsApi {
  Future<PageOf<AdminBooking>> list(AdminBookingQuery query);

  Future<AdminBookingDetail> get(int id);

  /// Cancela uma reserva `PENDING` (`POST /v1/bookings/{id}/cancel`, com
  /// `BOOKING_CANCEL_ANY`).
  Future<void> cancel(int id);

  Future<Refund> refund(
    int bookingId,
    RefundRequest request, {
    required String idempotencyKey,
  });

  Future<PageOf<Refund>> listRefunds(RefundQuery query);

  Future<Refund> retryRefund(int id);
}

class DioAdminBookingsApi implements AdminBookingsApi {
  const DioAdminBookingsApi(this._dio);

  final Dio _dio;

  @override
  Future<PageOf<AdminBooking>> list(AdminBookingQuery q) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/bookings',
      queryParameters: compact({
        'status': q.status == null ? null : bookingStatusToWire(q.status!),
        'bookableId': q.bookableId,
        'customerId': q.customerId,
        'createdFrom': q.from == null
            ? null
            : DateTime(
                q.from!.year,
                q.from!.month,
                q.from!.day,
              ).toUtc().toIso8601String(),
        'createdTo': q.to == null
            ? null
            : DateTime(
                q.to!.year,
                q.to!.month,
                q.to!.day,
                23,
                59,
                59,
                999,
              ).toUtc().toIso8601String(),
        'paid': q.paid,
        'page': q.page,
        'size': q.size,
      }),
    );
    return PageOf.fromJson(bodyOf(response), AdminBooking.fromJson);
  });

  @override
  Future<AdminBookingDetail> get(int id) => guarded(() async {
    final response = await _dio.get<Object>('/admin/bookings/$id');
    return AdminBookingDetail.fromJson(bodyOf(response));
  });

  @override
  Future<void> cancel(int id) =>
      guarded(() async => _dio.post<Object>('/bookings/$id/cancel'));

  @override
  Future<Refund> refund(
    int bookingId,
    RefundRequest request, {
    required String idempotencyKey,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/bookings/$bookingId/refund',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      data: compact({
        'reason': refundReasonToWire(request.reason),
        'note': request.note?.trim(),
        'override': request.override ? true : null,
      }),
    );
    return Refund.fromJson(bodyOf(response));
  });

  @override
  Future<PageOf<Refund>> listRefunds(RefundQuery q) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/refunds',
      queryParameters: compact({
        'status': q.status == null ? null : refundStatusToWire(q.status!),
        'page': q.page,
        'size': q.size,
      }),
    );
    return PageOf.fromJson(bodyOf(response), Refund.fromJson);
  });

  @override
  Future<Refund> retryRefund(int id) => guarded(() async {
    final response = await _dio.post<Object>('/admin/refunds/$id/retry');
    return Refund.fromJson(bodyOf(response));
  });
}
