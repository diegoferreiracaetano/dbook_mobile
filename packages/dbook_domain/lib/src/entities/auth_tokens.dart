import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

/// Par de tokens JWT — espelha `TokenResponse` do backend. Access token
/// expira em 15min, refresh token em 7 dias (config do backend); o refresh
/// é de uso único — cada `/auth/refresh` devolve um par novo.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;
}
