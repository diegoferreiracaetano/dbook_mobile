// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DestinationResponseDto _$DestinationResponseDtoFromJson(
  Map<String, dynamic> json,
) => _DestinationResponseDto(
  iataCode: json['iataCode'] as String,
  city: json['city'] as String,
  country: json['country'] as String,
  photoUrl: json['photoUrl'] as String,
  region: json['region'] as String,
  isPopular: json['isPopular'] as bool,
  lowestPrice: (json['lowestPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DestinationResponseDtoToJson(
  _DestinationResponseDto instance,
) => <String, dynamic>{
  'iataCode': instance.iataCode,
  'city': instance.city,
  'country': instance.country,
  'photoUrl': instance.photoUrl,
  'region': instance.region,
  'isPopular': instance.isPopular,
  'lowestPrice': instance.lowestPrice,
};
