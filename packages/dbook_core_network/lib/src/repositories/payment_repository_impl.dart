import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/payment_response_dto.dart';
import '../dtos/register_payment_request_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Payment> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/payments',
        data: RegisterPaymentRequestDto(
          bookingIds: bookingIds,
          cardLast4: cardLast4,
          cardholderName: cardholderName,
        ).toJson(),
      );

      return PaymentResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
