import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class DestinationReviewRepositoryImpl implements DestinationReviewRepository {
  const DestinationReviewRepositoryImpl(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static Json _body(Response<Object> response) =>
      response.data is Map<String, dynamic>
      ? response.data! as Json
      : <String, dynamic>{};

  static PublicReview _review(Json json) => PublicReview(
    id: json.count('id'),
    rating: json.count('rating'),
    comment: json.text('comment'),
    author: json.text('author'),
    edited: json.flag('edited'),
    createdAt: json.time('createdAt'),
  );

  @override
  Future<DestinationReviews> list(
    String iataCode, {
    ReviewSort sort = ReviewSort.recent,
    int page = 0,
    int size = 10,
  }) => _guard(() async {
    final response = await _dio.get<Object>(
      '/destinations/$iataCode/reviews',
      queryParameters: {
        'sort': sort == ReviewSort.recent ? 'RECENT' : 'RATING',
        'page': page,
        'size': size,
      },
    );
    final body = _body(response);
    final summary = body.obj('summary') ?? const <String, dynamic>{};
    final reviews = body.obj('reviews') ?? const <String, dynamic>{};
    final distribution = <int, int>{};
    final raw = summary.obj('distribution') ?? const <String, dynamic>{};
    for (final entry in raw.entries) {
      final stars = int.tryParse(entry.key);
      final count = entry.value;
      if (stars != null && count is num) distribution[stars] = count.toInt();
    }
    return DestinationReviews(
      summary: ReviewSummary(
        average: summary.decimal('average'),
        total: summary.count('total'),
        distribution: distribution,
      ),
      page: PublicReviewPage(
        items: reviews.list('items', _review),
        page: reviews.count('page'),
        totalPages: reviews.count('totalPages'),
        totalElements: reviews.count('totalElements'),
      ),
    );
  });

  @override
  Future<void> edit(int reviewId, {int? rating, String? comment}) => _guard(
    () async => _dio.patch<Object>(
      '/reviews/$reviewId',
      data: {'rating': ?rating, 'comment': ?comment},
    ),
  );

  @override
  Future<void> delete(int reviewId) =>
      _guard(() async => _dio.delete<Object>('/reviews/$reviewId'));

  @override
  Future<void> report(int reviewId, String reason) => _guard(
    () async => _dio.post<Object>(
      '/reviews/$reviewId/report',
      data: {'reason': reason},
    ),
  );
}
