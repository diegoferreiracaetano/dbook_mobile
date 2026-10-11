import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dbook_auth_interceptor.dart';

/// A URL base da API — o app precisa sobrescrever isso em
/// `ProviderScope(overrides: [...])`; não tem um default sensato aqui.
final baseUrlProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'Override baseUrlProvider with the real API base URL in main.dart',
  );
});

/// Liga o log de requisição/resposta do Dio (`LogInterceptor`). O app deve
/// sobrescrever com `kDebugMode` — nunca logar em produção.
final dbookNetworkLoggingProvider = Provider<bool>((ref) => false);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

/// Quem está chamando a API (versão e plataforma). O app sobrescreve com a
/// versão real do pacote; o padrão `unknown` é o que o servidor espera de
/// um cliente que não se identifica.
final appClientProvider = Provider<AppClientInfo>(
  (ref) => AppClientInfo.unknown,
);

/// Dio só pra chamadas de auth (`login`/`register`/`refresh`) — sem o
/// interceptor de token, pra nunca entrar em loop: a própria chamada de
/// refresh não pode disparar o fluxo de refresh de novo. Usado também pela
/// feature de auth (`PersistingAuthRepository`) pra fazer login/registro.
final authOnlyDioProvider = Provider<Dio>((ref) {
  return DbookDioClient.create(
    baseUrl: ref.watch(baseUrlProvider),
    logging: ref.watch(dbookNetworkLoggingProvider),
    appClient: ref.watch(appClientProvider),
  );
});

/// O `Dio` principal, com o token anexado em toda requisição e refresh
/// automático no 401 — é esse que toda feature autenticada deve consumir.
final dioProvider = Provider<Dio>((ref) {
  final dio = DbookDioClient.create(
    baseUrl: ref.watch(baseUrlProvider),
    logging: ref.watch(dbookNetworkLoggingProvider),
    appClient: ref.watch(appClientProvider),
  );
  final rawAuthRepository = AuthRepositoryImpl(ref.watch(authOnlyDioProvider));

  dio.interceptors.add(
    DbookAuthInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      authRepository: rawAuthRepository,
      dio: dio,
      onAccountBlocked: () => ref.read(accountBlockedProvider.notifier).block(),
    ),
  );

  return dio;
});

final appConfigRepositoryProvider = Provider<AppConfigRepository>(
  (ref) => AppConfigRepositoryImpl(ref.watch(authOnlyDioProvider)),
);

/// O que o ciclo de vida da API diz sobre esta instalação.
class UpdateInfo {
  const UpdateInfo({
    required this.status,
    this.storeUrl = '',
    this.latestVersion = '',
  });

  /// Em dia, ou sem como saber: nunca bloqueia.
  static const none = UpdateInfo(status: UpdateStatus.upToDate);

  final UpdateStatus status;
  final String storeUrl;
  final String latestVersion;
}

/// Consulta `GET /v1/app-config` ao abrir o app e compara com a versão
/// instalada. **Falha da consulta nunca bloqueia o uso**: sem rede, o app
/// abre como sempre (a regra de bloquear é do servidor, e só vale quando ele
/// responde).
final appUpdateProvider = FutureProvider<UpdateInfo>((ref) async {
  final client = ref.watch(appClientProvider);
  try {
    final config = await ref.watch(appConfigRepositoryProvider).fetch();
    final release = config.forPlatform(client.platform);
    return UpdateInfo(
      status: assessUpdate(currentVersion: client.version, release: release),
      storeUrl: release?.storeUrl ?? '',
      latestVersion: release?.latestVersion ?? '',
    );
  } on Object {
    return UpdateInfo.none;
  }
});

/// A conta foi bloqueada pela equipe: o app mostra uma tela própria em vez de
/// uma sequência de erros soltos. Ligado pelo login e pelo interceptor (um
/// bloqueio no meio da sessão).
class AccountBlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void block() => state = true;

  void clear() => state = false;
}

final accountBlockedProvider = NotifierProvider<AccountBlockedNotifier, bool>(
  AccountBlockedNotifier.new,
);
