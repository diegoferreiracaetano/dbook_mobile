import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL base da API do portal, com a versão (`https://api.../v1`). O app
/// sobrescreve com o `--dart-define` do ambiente; não há valor padrão
/// sensato aqui.
final adminBaseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError('Override adminBaseUrlProvider in main.dart');
});

/// Log de requisição/resposta do Dio: só em debug, nunca em produção.
final adminNetworkLoggingProvider = Provider<bool>((ref) => false);

/// Quem está chamando (versão e plataforma `web`), mandado em toda chamada.
final adminAppClientProvider = Provider<AppClientInfo>(
  (ref) => const AppClientInfo(version: 'unknown', platform: 'web'),
);

/// O "agora" do portal; os testes trocam por um relógio fixo.
final adminClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Tempo sem atividade até a saída automática, e o aviso antes dela.
final idleTimeoutProvider = Provider<Duration>(
  (ref) => const Duration(minutes: 15),
);
final idleWarningProvider = Provider<Duration>(
  (ref) => const Duration(minutes: 1),
);
