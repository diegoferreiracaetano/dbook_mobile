import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_booking_request_dto.freezed.dart';
part 'register_booking_request_dto.g.dart';

/// Corpo de `POST /bookings` — `customerId` vem do JWT no backend, não vai
/// no corpo.
@freezed
abstract class RegisterBookingRequestDto with _$RegisterBookingRequestDto {
  const factory RegisterBookingRequestDto({
    required int bookableId,
    required int seatId,
  }) = _RegisterBookingRequestDto;

  factory RegisterBookingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterBookingRequestDtoFromJson(json);
}
