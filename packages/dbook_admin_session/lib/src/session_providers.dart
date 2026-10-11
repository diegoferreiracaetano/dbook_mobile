import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_auth_interceptor.dart';
import 'session_config.dart';
import 'session_notifier.dart';
import 'session_state.dart';
import 'token_manager.dart';

Dio _newDio(Ref ref) {
  final dio = DbookDioClient.create(
    baseUrl: ref.watch(adminBaseUrlProvider),
    logging: ref.watch(adminNetworkLoggingProvider),
    appClient: ref.watch(adminAppClientProvider),
  );
  // O cookie de renovação é `httpOnly`: o navegador só o envia (e guarda o
  // novo) se a chamada pedir credenciais. O Dio na web lê esta chave.
  dio.options.extra['withCredentials'] = true;
  return dio;
}

/// Dio **sem** o interceptor de token: login, segundo fator, renovação, saída
/// e aceite de convite. A renovação não pode disparar a própria renovação.
final adminBareDioProvider = Provider<Dio>(_newDio);

/// O `AdminAuthApi` das chamadas que criam ou encerram a sessão.
final adminAuthApiProvider = Provider<AdminAuthApi>(
  (ref) => DioAdminAuthApi(ref.watch(adminBareDioProvider)),
);

final sessionTokenManagerProvider = Provider<SessionTokenManager>((ref) {
  return SessionTokenManager(() => ref.read(adminAuthApiProvider).refresh());
});

/// O `Dio` que toda área do portal usa: token anexado e renovação no `401`.
final adminDioProvider = Provider<Dio>((ref) {
  final dio = _newDio(ref);
  dio.interceptors.add(
    AdminAuthInterceptor(
      tokens: ref.read(sessionTokenManagerProvider),
      dio: dio,
      onSessionLost: () => ref
          .read(adminSessionProvider.notifier)
          .expire(SessionEndReason.expired),
    ),
  );
  return dio;
});

/// `me`, troca de senha e gestão do segundo fator: chamadas **logadas** do
/// mesmo contrato de autenticação.
final adminAccountApiProvider = Provider<AdminAuthApi>(
  (ref) => DioAdminAuthApi(ref.watch(adminDioProvider)),
);

final adminSessionProvider =
    NotifierProvider<AdminSessionNotifier, AdminSessionState>(
      AdminSessionNotifier.new,
    );

/// O perfil de quem está logado, ou `null` (sem sessão).
final staffProfileProvider = Provider<StaffProfile?>((ref) {
  final state = ref.watch(adminSessionProvider);
  return state is SessionSignedIn ? state.profile : null;
});

/// Se quem está logado tem a permissão (esconder/mostrar controles). Quem
/// autoriza de verdade é o servidor.
final canProvider = Provider.family<bool, Permission>(
  (ref, permission) =>
      ref.watch(staffProfileProvider)?.can(permission) ?? false,
);
