import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/destination_response_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  const DestinationRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    try {
      final response = await _dio.get<List<dynamic>>('/destinations');

      return response.data!
          .map(
            (json) => DestinationResponseDto.fromJson(
              json as Map<String, dynamic>,
            ).toDomain(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
