import 'dart:convert';

/// O token de acesso do portal vive **só aqui, em memória**: nunca em
/// `localStorage`, nunca em cookie legível (um XSS não o leva para fora).
/// Recarregar a página o apaga; a sessão volta pelo cookie `httpOnly` de
/// renovação, que script nenhum lê.
///
/// [refresh] garante **uma renovação por vez**: várias chamadas que levam
/// `401` ao mesmo tempo esperam o mesmo voo. O token de renovação é de uso
/// único no servidor, então duas renovações paralelas se invalidariam.
class SessionTokenManager {
  SessionTokenManager(this._refreshCall);

  final Future<String> Function() _refreshCall;

  String? _accessToken;
  DateTime? _expiresAt;
  Future<String>? _inFlight;

  String? get accessToken => _accessToken;
  DateTime? get expiresAt => _expiresAt;
  bool get hasToken => _accessToken != null;

  void setToken(String token) {
    _accessToken = token;
    _expiresAt = jwtExpiry(token);
  }

  void clear() {
    _accessToken = null;
    _expiresAt = null;
  }

  Future<String> refresh() => _inFlight ??= _run().whenComplete(() {
    _inFlight = null;
  });

  Future<String> _run() async {
    final token = await _refreshCall();
    setToken(token);
    return token;
  }

  /// Quanto falta para renovar em silêncio: o vencimento menos [margin].
  /// `null` se o token não diz quando vence.
  Duration? timeUntilRefresh(
    DateTime now, {
    Duration margin = const Duration(seconds: 60),
  }) {
    final expires = _expiresAt;
    if (expires == null) return null;
    final wait = expires.difference(now) - margin;
    return wait.isNegative ? Duration.zero : wait;
  }
}

/// O instante de vencimento (`exp`) de um JWT, sem validar assinatura: só o
/// servidor valida. Serve apenas para agendar a renovação.
DateTime? jwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final json = jsonDecode(payload);
    final exp = json is Map ? json['exp'] : null;
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  } on FormatException {
    return null;
  }
}
