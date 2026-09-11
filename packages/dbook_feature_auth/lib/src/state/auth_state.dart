import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Estado da sessão — `loggedOut` é o inicial (e o estado após logout ou
/// bootstrap sem sessão salva/refresh inválido).
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loggedOut() = AuthLoggedOut;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.loggedIn({required AuthTokens tokens}) = AuthLoggedIn;
  const factory AuthState.error(String message) = AuthError;
}
