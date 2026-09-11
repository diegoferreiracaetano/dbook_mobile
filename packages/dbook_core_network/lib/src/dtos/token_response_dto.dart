import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response_dto.freezed.dart';
part 'token_response_dto.g.dart';

/// Resposta de `POST /auth/login`, `/auth/register` (login automático não
/// se aplica) e `/auth/refresh`.
@freezed
abstract class TokenResponseDto with _$TokenResponseDto {
  const TokenResponseDto._();

  const factory TokenResponseDto({
    required String accessToken,
    required String refreshToken,
  }) = _TokenResponseDto;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);

  AuthTokens toDomain() {
    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }
}
