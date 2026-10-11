import 'dart:async';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_config.dart';
import 'session_providers.dart';
import 'session_state.dart';

/// A sessão do portal. Os métodos que falam com o servidor deixam o
/// `DbookNetworkException` subir: quem os chama (a tela de login) decide a
/// mensagem pelo `code`.
class AdminSessionNotifier extends Notifier<AdminSessionState> {
  Timer? _renewal;
  String? _pendingAccessToken;

  @override
  AdminSessionState build() {
    ref.onDispose(() => _renewal?.cancel());
    Future<void>.microtask(restore);
    return const SessionRestoring();
  }

  /// Ao abrir ou recarregar a página: o token em memória se perdeu, mas o
  /// cookie `httpOnly` ainda pode renovar a sessão.
  Future<void> restore() async {
    try {
      await ref.read(sessionTokenManagerProvider).refresh();
      await _loadProfile();
    } on Object {
      _signOutLocally(SessionEndReason.none);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final outcome = await ref
        .read(adminAuthApiProvider)
        .login(email: email, password: password);
    switch (outcome) {
      case LoginSucceeded(:final accessToken):
        await _completeSignIn(accessToken);
      case LoginNeedsSecondFactor(
        :final challengeToken,
        :final enrollmentRequired,
      ):
        state = SessionChallenge(
          challengeToken: challengeToken,
          enrollmentRequired: enrollmentRequired,
        );
    }
  }

  Future<void> verifyTwoFactor(String code) async {
    final challenge = _challenge();
    final token = await ref
        .read(adminAuthApiProvider)
        .verifyTwoFactor(challengeToken: challenge.challengeToken, code: code);
    await _completeSignIn(token);
  }

  /// Passo 1 do cadastro do autenticador (durante o login).
  Future<TwoFactorEnrollment> startEnrollment() => ref
      .read(adminAuthApiProvider)
      .enrollWithChallenge(_challenge().challengeToken);

  /// Passo 2: confirma o código. Mostra os códigos de recuperação **antes** de
  /// entrar: eles não aparecem de novo.
  Future<void> confirmEnrollment(String code) async {
    final enrolled = await ref
        .read(adminAuthApiProvider)
        .confirmWithChallenge(
          challengeToken: _challenge().challengeToken,
          code: code,
        );
    _pendingAccessToken = enrolled.accessToken;
    state = SessionRecoveryCodes(enrolled.recoveryCodes);
  }

  /// O usuário guardou os códigos: agora sim a sessão começa.
  Future<void> acknowledgeRecoveryCodes() async {
    final token = _pendingAccessToken;
    if (token == null) return;
    _pendingAccessToken = null;
    await _completeSignIn(token);
  }

  /// Volta do segundo fator para a tela de e-mail e senha.
  void cancelChallenge() => _signOutLocally(SessionEndReason.none);

  Future<void> logout() async {
    try {
      await ref.read(adminAuthApiProvider).logout();
    } on Object {
      // Sair sempre funciona do lado de cá, mesmo com a API fora do ar.
    }
    _signOutLocally(SessionEndReason.loggedOut);
  }

  /// A sessão acabou por ociosidade ou porque a renovação falhou.
  void expire(SessionEndReason reason) => _signOutLocally(reason);

  /// Depois de trocar a senha o servidor encerra todas as sessões.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ref
        .read(adminAccountApiProvider)
        .changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
    _signOutLocally(SessionEndReason.passwordChanged);
  }

  /// Atualiza o perfil (depois de ligar ou desligar o segundo fator).
  Future<void> reloadProfile() => _loadProfile();

  Future<void> _completeSignIn(String accessToken) async {
    ref.read(sessionTokenManagerProvider).setToken(accessToken);
    try {
      await _loadProfile();
    } on Object {
      _signOutLocally(SessionEndReason.none);
      rethrow;
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(adminAccountApiProvider).me();
    state = SessionSignedIn(profile);
    _scheduleRenewal();
  }

  void _scheduleRenewal() {
    _renewal?.cancel();
    final tokens = ref.read(sessionTokenManagerProvider);
    final wait = tokens.timeUntilRefresh(ref.read(adminClockProvider)());
    if (wait == null) return;
    _renewal = Timer(wait, _renewSilently);
  }

  Future<void> _renewSilently() async {
    try {
      await ref.read(sessionTokenManagerProvider).refresh();
      _scheduleRenewal();
    } on Object {
      _signOutLocally(SessionEndReason.expired);
    }
  }

  void _signOutLocally(SessionEndReason reason) {
    _renewal?.cancel();
    _pendingAccessToken = null;
    ref.read(sessionTokenManagerProvider).clear();
    state = SessionSignedOut(reason);
  }

  SessionChallenge _challenge() {
    final current = state;
    if (current is! SessionChallenge) {
      throw StateError('No second-factor challenge in progress');
    }
    return current;
  }
}
