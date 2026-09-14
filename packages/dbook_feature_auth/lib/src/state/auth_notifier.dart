import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
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
      await _syncProfile();
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
      state = AuthState.loggedIn(tokens: tokens, email: email);
      await _syncProfile();
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
    required String name,
  }) async {
    state = const AuthState.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(email: email, password: password, name: name);
      final tokens = await repository.login(email: email, password: password);
      state = AuthState.loggedIn(tokens: tokens, email: email, name: name);
      await _syncProfile();
    } on DbookNetworkException catch (error) {
      state = AuthState.error(error.message);
    }
  }

  /// Busca o perfil real (`GET /users/me`) e substitui o que o formulário
  /// digitou pelo que o backend tem — também é o único jeito de recuperar
  /// e-mail/nome depois do bootstrap (refresh de token não devolve nenhum
  /// dos dois). Falha de rede aqui não derruba a sessão: o token já é
  /// válido, então só mantém o que já tinha (mesmo que incompleto).
  Future<void> _syncProfile() async {
    final current = state;
    if (current is! AuthLoggedIn) return;
    try {
      final user = await ref.read(authRepositoryProvider).getMe();
      state = current.copyWith(email: user.email, name: user.name);
    } on DbookNetworkException {
      // mantém o estado como estava — ver comentário acima.
    }
  }

  /// `PATCH /users/me`. Deixa a exceção de rede propagar: quem chama (a
  /// tela de edição de perfil) decide como mostrar o erro.
  Future<void> updateName(String name) async {
    final current = state;
    if (current is! AuthLoggedIn) return;
    final updated = await ref.read(authRepositoryProvider).updateName(name);
    state = current.copyWith(email: updated.email, name: updated.name);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState.loggedOut();
  }
}
