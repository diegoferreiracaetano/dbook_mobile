import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_review_request_dto.freezed.dart';
part 'create_review_request_dto.g.dart';

/// Corpo de `POST /Reviews`
@freezed
abstract class CreateReviewRequestDto with _$CreateReviewRequestDto {
  const factory CreateReviewRequestDto({
    required int bookingId,
    required int rating,
    required String comment,
  }) = _CreateReviewRequestDto;

  factory CreateReviewRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestDtoFromJson(json);
}
