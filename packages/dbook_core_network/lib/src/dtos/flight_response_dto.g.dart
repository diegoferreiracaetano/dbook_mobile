// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlightResponseDto _$FlightResponseDtoFromJson(Map<String, dynamic> json) =>
    _FlightResponseDto(
      id: (json['id'] as num).toInt(),
      flightNumber: json['flightNumber'] as String,
      airlineIataCode: json['airlineIataCode'] as String,
      airlineName: json['airlineName'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      seatClass: json['seatClass'] as String,
      price: (json['price'] as num).toDouble(),
      availableCapacity: (json['availableCapacity'] as num).toInt(),
      aircraftType: json['aircraftType'] as String,
      seatLayout: (json['seatLayout'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$FlightResponseDtoToJson(_FlightResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flightNumber': instance.flightNumber,
      'airlineIataCode': instance.airlineIataCode,
      'airlineName': instance.airlineName,
      'origin': instance.origin,
      'destination': instance.destination,
      'departureTime': instance.departureTime,
      'arrivalTime': instance.arrivalTime,
      'seatClass': instance.seatClass,
      'price': instance.price,
      'availableCapacity': instance.availableCapacity,
      'aircraftType': instance.aircraftType,
      'seatLayout': instance.seatLayout,
    };
