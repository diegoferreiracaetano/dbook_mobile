import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/suggest_flights_request_dto.dart';
import '../dtos/suggest_flights_response_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class AiSuggestionRepositoryImpl implements AiSuggestionRepository {
  const AiSuggestionRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AiSuggestion>> suggest(String query) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/ai/suggestions',
        data: SuggestFlightsRequestDto(query: query).toJson(),
      );

      return SuggestFlightsResponseDto.fromJson(response.data!).suggestions
          .map((item) => item.toDomain())
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
