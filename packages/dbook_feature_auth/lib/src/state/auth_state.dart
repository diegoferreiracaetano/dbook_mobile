import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Estado da sessão — `loggedOut` é o inicial (e o estado após logout ou
/// bootstrap sem sessão salva/refresh inválido).
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loggedOut() = AuthLoggedOut;
  const factory AuthState.loading() = AuthLoading;

  /// [email]/[name] começam com o que o usuário digitou (ou `null`, no
  /// bootstrap) e são enriquecidos logo em seguida com os dados reais via
  /// `GET /users/me` (ver `AuthNotifier._syncProfile`) — por isso ambos
  /// continuam nullable: o enriquecimento pode falhar (rede), e a sessão
  /// não deve cair por causa disso.
  const factory AuthState.loggedIn({
    required AuthTokens tokens,
    String? email,
    String? name,
  }) = AuthLoggedIn;
  const factory AuthState.error(String message) = AuthError;
}
