import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Estado da sessão — `loggedOut` é o inicial (e o estado após logout ou
/// bootstrap sem sessão salva/refresh inválido).
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loggedOut() = AuthLoggedOut;
  const factory AuthState.loading() = AuthLoading;
  /// [email] é o que o usuário digitou no login/registro — só existe em
  /// memória (não há `GET /users/me` no backend pra confirmar depois),
  /// perdido ao reabrir o app; o bootstrap (refresh de token salvo) não
  /// tem como preenchê-lo, então fica `null` nesse caso.
  const factory AuthState.loggedIn({
    required AuthTokens tokens,
    String? email,
  }) = AuthLoggedIn;
  const factory AuthState.error(String message) = AuthError;
}
