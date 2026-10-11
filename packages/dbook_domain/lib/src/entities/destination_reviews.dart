/// Uma avaliação pública de um destino: sem e-mail nem id de cliente, só o
/// primeiro nome do autor como o servidor o devolve.
class PublicReview {
  const PublicReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.author,
    required this.edited,
    this.createdAt,
  });

  final int id;
  final int rating;
  final String comment;
  final String author;
  final bool edited;
  final DateTime? createdAt;

  PublicReview copyWith({int? rating, String? comment}) => PublicReview(
    id: id,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    author: author,
    edited: rating != null || comment != null ? true : edited,
    createdAt: createdAt,
  );
}

/// Média, total e quantas avaliações há de cada nota (1 a 5).
class ReviewSummary {
  const ReviewSummary({
    required this.total,
    required this.distribution,
    this.average,
  });

  final double? average;
  final int total;

  /// nota (1 a 5) -> quantidade
  final Map<int, int> distribution;

  int countFor(int stars) => distribution[stars] ?? 0;
}

class PublicReviewPage {
  const PublicReviewPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });

  final List<PublicReview> items;
  final int page;
  final int totalPages;
  final int totalElements;

  bool get hasMore => page + 1 < totalPages;
}

class DestinationReviews {
  const DestinationReviews({required this.summary, required this.page});

  final ReviewSummary summary;
  final PublicReviewPage page;
}

enum ReviewSort { recent, rating }
