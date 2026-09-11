import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../wire_enums.dart';

part 'booking_response_dto.freezed.dart';
part 'booking_response_dto.g.dart';

/// Resposta de `POST /bookings` e `POST /bookings/{id}/cancel`.
@freezed
abstract class BookingResponseDto with _$BookingResponseDto {
  const BookingResponseDto._();

  const factory BookingResponseDto({
    required int id,
    required int? bookableId,
    required int seatId,
    required int customerId,
    required String status,
  }) = _BookingResponseDto;

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseDtoFromJson(json);

  Booking toDomain() {
    final resolvedBookableId = bookableId;
    if (resolvedBookableId == null) {
      // `bookableId` só é nulo no tipo do backend porque herda de
      // `Bookable.id: Long?` (nulo antes de persistir) — numa resposta de
      // API, a reserva já existe no banco, então isso nunca deveria
      // acontecer de verdade.
      throw StateError(
        'BookingResponseDto.bookableId was null for booking $id',
      );
    }

    return Booking(
      id: id,
      bookableId: resolvedBookableId,
      seatId: seatId,
      customerId: customerId,
      status: bookingStatusFromWire(status),
    );
  }
}
