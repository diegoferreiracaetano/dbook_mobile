// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeatResponseDto _$SeatResponseDtoFromJson(Map<String, dynamic> json) =>
    _SeatResponseDto(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$SeatResponseDtoToJson(_SeatResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'status': instance.status,
    };
