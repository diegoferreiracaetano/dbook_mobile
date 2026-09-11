// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlightResponseDto _$FlightResponseDtoFromJson(Map<String, dynamic> json) =>
    _FlightResponseDto(
      id: (json['id'] as num).toInt(),
      flightNumber: json['flightNumber'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      seatClass: json['seatClass'] as String,
      price: (json['price'] as num).toDouble(),
      availableCapacity: (json['availableCapacity'] as num).toInt(),
    );

Map<String, dynamic> _$FlightResponseDtoToJson(_FlightResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flightNumber': instance.flightNumber,
      'origin': instance.origin,
      'destination': instance.destination,
      'departureTime': instance.departureTime,
      'arrivalTime': instance.arrivalTime,
      'seatClass': instance.seatClass,
      'price': instance.price,
      'availableCapacity': instance.availableCapacity,
    };
