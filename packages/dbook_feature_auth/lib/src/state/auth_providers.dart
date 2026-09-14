import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/persisting_auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// O `AuthRepository` que login/registro/bootstrap/perfil usam — salva o
/// par de tokens sozinho a cada login/refresh bem-sucedido. Login/registro/
/// refresh usam `authOnlyDioProvider` (sem sessão ainda pra anexar);
/// `getMe()`/`updateName()` usam `dioProvider` (`dbook_core_session`), que já
/// anexa o token — ver o comentário em `PersistingAuthRepository`.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final networkRepository = AuthRepositoryImpl(ref.watch(authOnlyDioProvider));
  final authenticatedRepository = AuthRepositoryImpl(ref.watch(dioProvider));
  return PersistingAuthRepository(
    networkRepository: networkRepository,
    authenticatedRepository: authenticatedRepository,
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
