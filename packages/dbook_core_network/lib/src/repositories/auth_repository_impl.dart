import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';

import '../dtos/login_request_dto.dart';
import '../dtos/refresh_request_dto.dart';
import '../dtos/register_user_request_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_response_dto.dart';
import '../exceptions/dbook_network_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: RegisterUserRequestDto(email: email, password: password).toJson(),
      );

      return UserResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: LoginRequestDto(email: email, password: password).toJson(),
      );

      return TokenResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );

      return TokenResponseDto.fromJson(response.data!).toDomain();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
