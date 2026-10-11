// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentResponseDto _$PaymentResponseDtoFromJson(Map<String, dynamic> json) =>
    _PaymentResponseDto(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      cardLast4: json['cardLast4'] as String,
      bookingIds: (json['bookingIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      promoCode: json['promoCode'] as String?,
    );

Map<String, dynamic> _$PaymentResponseDtoToJson(_PaymentResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'cardLast4': instance.cardLast4,
      'bookingIds': instance.bookingIds,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'promoCode': instance.promoCode,
    };
