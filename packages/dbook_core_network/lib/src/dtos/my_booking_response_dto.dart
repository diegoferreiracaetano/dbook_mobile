import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../wire_enums.dart';
import 'flight_response_dto.dart';
import 'seat_response_dto.dart';

part 'my_booking_response_dto.freezed.dart';
part 'my_booking_response_dto.g.dart';

/// Item de `GET /bookings` ("minhas viagens") — já vem com o assento e o
/// voo completos, sem chamada extra.
@freezed
abstract class MyBookingResponseDto with _$MyBookingResponseDto {
  const MyBookingResponseDto._();

  const factory MyBookingResponseDto({
    required int? id,
    required String status,
    required SeatResponseDto seat,
    required FlightResponseDto flight,
  }) = _MyBookingResponseDto;

  factory MyBookingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MyBookingResponseDtoFromJson(json);

  MyBooking toDomain() {
    final resolvedId = id;
    if (resolvedId == null) {
      // Mesmo caso de `BookingResponseDto.bookableId`: só é nulo no tipo
      // do backend porque `Booking.id` é `Long?` antes de persistir — numa
      // resposta de listagem a reserva já existe, então isso nunca deveria
      // acontecer de verdade.
      throw StateError('MyBookingResponseDto.id was null');
    }

    final resolvedFlight = flight.toDomain();
    return MyBooking(
      id: resolvedId,
      status: bookingStatusFromWire(status),
      flight: resolvedFlight,
      seat: seat.toDomain(resolvedFlight.id),
    );
  }
}
