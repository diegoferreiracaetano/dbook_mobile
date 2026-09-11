// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_booking_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterBookingRequestDto _$RegisterBookingRequestDtoFromJson(
  Map<String, dynamic> json,
) => _RegisterBookingRequestDto(
  bookableId: (json['bookableId'] as num).toInt(),
  seatId: (json['seatId'] as num).toInt(),
);

Map<String, dynamic> _$RegisterBookingRequestDtoToJson(
  _RegisterBookingRequestDto instance,
) => <String, dynamic>{
  'bookableId': instance.bookableId,
  'seatId': instance.seatId,
};
