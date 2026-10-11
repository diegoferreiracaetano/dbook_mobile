import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';
import '../json_read.dart';

class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PromoPreview> validate({
    required String code,
    required List<int> bookingIds,
  }) async {
    try {
      final response = await _dio.post<Object>(
        '/promo-codes/validate',
        data: {'code': code.trim(), 'bookingIds': bookingIds},
      );
      final body = response.data is Map<String, dynamic>
          ? response.data! as Json
          : <String, dynamic>{};
      return PromoPreview(
        code: body.text('code'),
        subtotal: body.decimal('subtotal') ?? 0,
        discount: body.decimal('discount') ?? 0,
        total: body.decimal('total') ?? 0,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
