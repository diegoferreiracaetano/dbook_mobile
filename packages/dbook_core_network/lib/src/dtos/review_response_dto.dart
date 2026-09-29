import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_response_dto.freezed.dart';
part 'review_response_dto.g.dart';

/// Resposta de `POST /reviews`.
@freezed
abstract class ReviewResponseDto with _$ReviewResponseDto {
  const ReviewResponseDto._();

  const factory ReviewResponseDto({
    required int id,
    required int bookingId,
    required int customerId,
    required int rating,
    required String comment,
    required DateTime createdAt,
  }) = _ReviewResponseDto;

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseDtoFromJson(json);

  Review toDomain() => Review(
    id: id,
    bookingId: bookingId,
    customerId: customerId,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
  );
}
