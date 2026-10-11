import 'package:dbook_admin_data/dbook_admin_data.dart';

/// Por que a sessão terminou: mostra a mensagem certa no login.
enum SessionEndReason { none, loggedOut, idle, expired, passwordChanged }

/// Onde está a sessão do portal.
sealed class AdminSessionState {
  const AdminSessionState();
}

/// Tentando voltar pela renovação (cookie) ao abrir ou recarregar a página.
class SessionRestoring extends AdminSessionState {
  const SessionRestoring();
}

class SessionSignedOut extends AdminSessionState {
  const SessionSignedOut([this.reason = SessionEndReason.none]);

  final SessionEndReason reason;
}

/// Senha certa, falta o segundo fator.
class SessionChallenge extends AdminSessionState {
  const SessionChallenge({
    required this.challengeToken,
    required this.enrollmentRequired,
  });

  final String challengeToken;
  final bool enrollmentRequired;
}

/// Autenticador cadastrado: mostra os códigos de recuperação (uma vez) antes
/// de entrar.
class SessionRecoveryCodes extends AdminSessionState {
  const SessionRecoveryCodes(this.codes);

  final List<String> codes;
}

class SessionSignedIn extends AdminSessionState {
  const SessionSignedIn(this.profile);

  final StaffProfile profile;
}
