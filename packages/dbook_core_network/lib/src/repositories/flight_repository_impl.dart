import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/flight_response_dto.dart';
import '../dtos/seat_response_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class FlightRepositoryImpl implements FlightRepository {
  const FlightRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/flights/search',
        queryParameters: {
          'origin': originIataCode,
          'destination': destinationIataCode,
          'date': _formatDate(date),
        },
      );

      return response.data!
          .map(
            (json) =>
                FlightResponseDto.fromJson(json as Map<String, dynamic>)
                    .toDomain(),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<Seat>> getSeats(int bookableId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/bookables/$bookableId/seats',
      );

      return response.data!
          .map(
            (json) =>
                SeatResponseDto.fromJson(json as Map<String, dynamic>)
                    .toDomain(bookableId),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static String _formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}
