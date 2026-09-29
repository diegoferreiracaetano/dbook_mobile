import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/create_review_request_dto.dart';
import '../dtos/review_response_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Review> create({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/reviews',
        data: CreateReviewRequestDto(
          bookingId: bookingId,
          rating: rating,
          comment: comment,
        ).toJson(),
      );

      return ReviewResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
