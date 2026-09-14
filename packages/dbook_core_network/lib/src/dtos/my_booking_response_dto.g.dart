// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_booking_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyBookingResponseDto _$MyBookingResponseDtoFromJson(
  Map<String, dynamic> json,
) => _MyBookingResponseDto(
  id: (json['id'] as num?)?.toInt(),
  status: json['status'] as String,
  seat: SeatResponseDto.fromJson(json['seat'] as Map<String, dynamic>),
  flight: FlightResponseDto.fromJson(json['flight'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MyBookingResponseDtoToJson(
  _MyBookingResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'seat': instance.seat,
  'flight': instance.flight,
};
