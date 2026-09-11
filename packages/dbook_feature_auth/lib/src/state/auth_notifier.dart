import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'auth_state.dart';

/// Orquestra login/registro/logout e o bootstrap de sessão. Lê
/// `authRepositoryProvider` (já é o [PersistingAuthRepository], que salva
/// tokens sozinho em login/refresh) e `tokenStorageProvider` só pra ler no
/// bootstrap e limpar no logout — operações que não fazem sentido no port
/// `AuthRepository` do domínio.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.loggedOut();

  /// Roda na abertura do app: se houver uma sessão salva, tenta validar
  /// (refrescar) no servidor — decodificar o JWT localmente não pegaria
  /// revogação do lado do backend. Refresh inválido/expirado limpa o
  /// storage e volta pra `loggedOut`.
  Future<void> bootstrap() async {
    state = const AuthState.loading();

    final tokenStorage = ref.read(tokenStorageProvider);
    final stored = await tokenStorage.readTokens();
    if (stored == null) {
      state = const AuthState.loggedOut();
      return;
    }

    try {
      final refreshed = await ref
          .read(authRepositoryProvider)
          .refresh(stored.refreshToken);
      state = AuthState.loggedIn(tokens: refreshed);
    } on DbookNetworkException {
      await tokenStorage.clear();
      state = const AuthState.loggedOut();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final tokens = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = AuthState.loggedIn(tokens: tokens);
    } on DbookNetworkException catch (error) {
      state = AuthState.error(error.message);
    }
  }

  /// `/auth/register` não devolve tokens (só cria o usuário) — pra uma
  /// experiência sem atrito, loga automaticamente com as mesmas
  /// credenciais logo em seguida.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(email: email, password: password);
      final tokens = await repository.login(email: email, password: password);
      state = AuthState.loggedIn(tokens: tokens);
    } on DbookNetworkException catch (error) {
      state = AuthState.error(error.message);
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState.loggedOut();
  }
}
