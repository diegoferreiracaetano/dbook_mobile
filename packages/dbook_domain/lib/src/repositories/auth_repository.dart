import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Porta pra autenticação. Não inclui logout — isso é só limpar o storage
/// local (M3), não uma chamada de rede.
abstract interface class AuthRepository {
  /// `POST /auth/register`
  Future<User> register({required String email, required String password});

  /// `POST /auth/login`
  Future<AuthTokens> login({required String email, required String password});

  /// `POST /auth/refresh` — o refresh token é de uso único; a resposta
  /// sempre traz um par novo.
  Future<AuthTokens> refresh(String refreshToken);
}
