import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/persisting_auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// O `AuthRepository` que login/registro/bootstrap usam — salva o par de
/// tokens sozinho a cada login/refresh bem-sucedido. Usa `authOnlyDioProvider`
/// (`dbook_core_session`) — o Dio sem o interceptor de token, já que login e
/// registro não têm sessão ainda pra anexar.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final networkRepository = AuthRepositoryImpl(ref.watch(authOnlyDioProvider));
  return PersistingAuthRepository(
    networkRepository: networkRepository,
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
