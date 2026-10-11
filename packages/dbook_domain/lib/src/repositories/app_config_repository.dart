import '../entities/app_config.dart';

/// Porta do ciclo de vida do app (`GET /v1/app-config`, público).
abstract interface class AppConfigRepository {
  Future<AppConfig> fetch();
}
