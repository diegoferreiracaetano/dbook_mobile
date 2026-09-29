// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateReviewRequestDto _$CreateReviewRequestDtoFromJson(
  Map<String, dynamic> json,
) => _CreateReviewRequestDto(
  bookingId: (json['bookingId'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$CreateReviewRequestDtoToJson(
  _CreateReviewRequestDto instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'rating': instance.rating,
  'comment': instance.comment,
};
