/// Configuração do ambiente, vinda de `--dart-define` na hora do build. Só
/// valores **públicos**: o bundle web é de quem o baixar.
///
/// ```
/// flutter build web --dart-define=API_BASE_URL=https://api.exemplo.com/v1 \
///   --dart-define=APP_ENV=production --dart-define=APP_VERSION=1.4.0
/// ```
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.environment,
    required this.version,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/v1',
    ),
    environment: String.fromEnvironment('APP_ENV', defaultValue: 'local'),
    version: String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0+1'),
  );

  final String apiBaseUrl;
  final String environment;
  final String version;

  bool get isProduction => environment == 'production';

  /// A raiz do servidor, sem `/v1`: onde ficam `/health` e o actuator.
  String get apiRoot => apiBaseUrl.replaceFirst(RegExp(r'/v\d+/?$'), '');
}
