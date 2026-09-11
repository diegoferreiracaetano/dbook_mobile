import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dbook_auth_interceptor.dart';
import '../data/persisting_auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

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

/// Dio só pra chamadas de auth (`login`/`register`/`refresh`) — sem o
/// interceptor de token, pra nunca entrar em loop: a própria chamada de
/// refresh não pode disparar o fluxo de refresh de novo.
final _authOnlyDioProvider = Provider<Dio>((ref) {
  return DbookDioClient.create(
    baseUrl: ref.watch(baseUrlProvider),
    logging: ref.watch(dbookNetworkLoggingProvider),
  );
});

/// O `Dio` principal, com o token anexado em toda requisição e refresh
/// automático no 401 — é esse que toda outra feature deve consumir.
final dioProvider = Provider<Dio>((ref) {
  final dio = DbookDioClient.create(
    baseUrl: ref.watch(baseUrlProvider),
    logging: ref.watch(dbookNetworkLoggingProvider),
  );
  final rawAuthRepository = AuthRepositoryImpl(ref.watch(_authOnlyDioProvider));

  dio.interceptors.add(
    DbookAuthInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      authRepository: rawAuthRepository,
      dio: dio,
    ),
  );

  return dio;
});

/// O `AuthRepository` que login/registro/bootstrap usam — salva o par de
/// tokens sozinho a cada login/refresh bem-sucedido.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final networkRepository = AuthRepositoryImpl(ref.watch(_authOnlyDioProvider));
  return PersistingAuthRepository(
    networkRepository: networkRepository,
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
