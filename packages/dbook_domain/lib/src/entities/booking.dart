import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_status.dart';

part 'booking.freezed.dart';

/// Reserva — espelha `BookingResponse` do backend.
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required int id,
    required int bookableId,
    required int seatId,
    required int customerId,
    required BookingStatus status,
  }) = _Booking;
}
