import '../entities/destination_reviews.dart';

/// Porta das avaliações públicas de um destino e do que o autor (ou outro
/// cliente) faz com elas (`/v1/destinations/{iata}/reviews`, `/v1/reviews/*`).
abstract interface class DestinationReviewRepository {
  Future<DestinationReviews> list(
    String iataCode, {
    ReviewSort sort = ReviewSort.recent,
    int page = 0,
    int size = 10,
  });

  /// Só o autor edita (`403` para outro); manda só o que mudou.
  Future<void> edit(int reviewId, {int? rating, String? comment});

  Future<void> delete(int reviewId);

  /// Denunciar a avaliação de outra pessoa (`409` se já denunciou ou é sua).
  Future<void> report(int reviewId, String reason);
}
