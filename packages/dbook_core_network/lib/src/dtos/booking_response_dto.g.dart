// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingResponseDto _$BookingResponseDtoFromJson(Map<String, dynamic> json) =>
    _BookingResponseDto(
      id: (json['id'] as num).toInt(),
      bookableId: (json['bookableId'] as num?)?.toInt(),
      seatId: (json['seatId'] as num).toInt(),
      customerId: (json['customerId'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$BookingResponseDtoToJson(_BookingResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookableId': instance.bookableId,
      'seatId': instance.seatId,
      'customerId': instance.customerId,
      'status': instance.status,
    };
