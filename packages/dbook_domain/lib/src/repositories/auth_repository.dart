import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Porta pra autenticação e pro próprio perfil (mesmo agregado "sessão").
/// Não inclui logout — isso é só limpar o storage local (M3), não uma
/// chamada de rede.
abstract interface class AuthRepository {
  /// `POST /auth/register`
  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  /// `POST /auth/login`
  Future<AuthTokens> login({required String email, required String password});

  /// `POST /auth/refresh` — o refresh token é de uso único; a resposta
  /// sempre traz um par novo.
  Future<AuthTokens> refresh(String refreshToken);

  /// `GET /users/me` — exige sessão ativa (usa o Dio autenticado).
  Future<User> getMe();

  /// `PATCH /users/me` — exige sessão ativa.
  Future<User> updateName(String name);
}
