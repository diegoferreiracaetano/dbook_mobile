import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_status.dart';
import 'flight.dart';
import 'seat.dart';

part 'my_booking.freezed.dart';

/// Uma reserva do usuário autenticado, já com o [Flight] e o [Seat]
/// completos — espelha `MyBookingResponse` do backend (`GET /bookings`,
/// "minhas viagens"). Diferente de [Booking] (resposta de `POST /bookings`
/// e `POST /bookings/{id}/cancel`, só com os ids), esta é a forma que a
/// listagem devolve — o backend já resolve a composição, o app só exibe.
@freezed
abstract class MyBooking with _$MyBooking {
  const factory MyBooking({
    required int id,
    required BookingStatus status,
    required Flight flight,
    required Seat seat,
  }) = _MyBooking;
}
