// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_payment_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterPaymentRequestDto _$RegisterPaymentRequestDtoFromJson(
  Map<String, dynamic> json,
) => _RegisterPaymentRequestDto(
  bookingIds: (json['bookingIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  cardLast4: json['cardLast4'] as String,
  cardholderName: json['cardholderName'] as String,
);

Map<String, dynamic> _$RegisterPaymentRequestDtoToJson(
  _RegisterPaymentRequestDto instance,
) => <String, dynamic>{
  'bookingIds': instance.bookingIds,
  'cardLast4': instance.cardLast4,
  'cardholderName': instance.cardholderName,
};
