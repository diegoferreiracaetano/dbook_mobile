import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

/// Implementação real de [TokenStorage] — Keychain no iOS, EncryptedSharedPreferences
/// no Android.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'dbook_access_token';
  static const _refreshTokenKey = 'dbook_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  @override
  Future<AuthTokens?> readTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) return null;

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
