import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../exceptions/dbook_network_exception.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  const PrivacyRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> exportMyData() async {
    try {
      final response = await _dio.get<Object>('/users/me/export');
      final data = response.data;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> deleteMyAccount({required String password}) async {
    try {
      await _dio.delete<Object>('/users/me', data: {'password': password});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
