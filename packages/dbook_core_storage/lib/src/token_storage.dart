import 'package:dbook_domain/dbook_domain.dart';

/// Porta pra persistir o par de tokens localmente — a implementação real
/// ([SecureTokenStorage]) usa `flutter_secure_storage`; a sessão (M3) só
/// depende dessa interface.
abstract interface class TokenStorage {
  Future<void> saveTokens(AuthTokens tokens);

  /// `null` quando não há sessão salva (ou só um dos dois tokens existe,
  /// o que é tratado como "sem sessão" — um par incompleto não serve).
  Future<AuthTokens?> readTokens();

  Future<void> clear();
}
