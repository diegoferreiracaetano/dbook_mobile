import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

/// Avaliação de uma reserva confirmada — espelha `ReviewResponse` do
/// backend. Só existe depois que a reserva vira CONFIRMED (o backend
/// recusa criar antes disso).
@freezed
abstract class Review with _$Review {
  const factory Review({
    required int id,
    required int bookingId,
    required int customerId,
    required int rating,
    required String comment,
    required DateTime createdAt,
  }) = _Review;
}
