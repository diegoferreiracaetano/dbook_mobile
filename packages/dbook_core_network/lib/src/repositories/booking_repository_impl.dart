import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/booking_response_dto.dart';
import '../dtos/register_booking_request_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/bookings',
        data: RegisterBookingRequestDto(
          bookableId: bookableId,
          seatId: seatId,
        ).toJson(),
      );

      return BookingResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingId/cancel',
      );

      return BookingResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
