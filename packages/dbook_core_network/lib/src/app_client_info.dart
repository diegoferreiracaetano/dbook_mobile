/// O que o app diz ao servidor sobre si mesmo em toda chamada. O servidor
/// normaliza ambos para um conjunto pequeno (versão `1.4.2+17` vira `1.4`;
/// plataforma só `android`, `ios`, `web`), então mandar um valor "sujo" não
/// quebra nada, só cai em `unknown`.
class AppClientInfo {
  const AppClientInfo({required this.version, required this.platform});

  /// Para quem ainda não sabe quem é (testes, ferramentas): o servidor conta
  /// como `unknown`.
  static const unknown = AppClientInfo(version: 'unknown', platform: 'unknown');

  final String version;
  final String platform;

  Map<String, String> get headers => {
    'X-App-Version': version,
    'X-App-Platform': platform,
  };
}
