// Os parâmetros nomeados precisam ser públicos, mas os campos que eles
// preenchem são privados — não dá pra usar initializing formals aqui.
// ignore_for_file: prefer_initializing_formals

import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';

/// Decora o `AuthRepository` de rede (`dbook_core_network`) salvando o par
/// de tokens no storage seguro sempre que um login/refresh der certo. O
/// registro não salva nada — `/auth/register` não devolve tokens.
class PersistingAuthRepository implements AuthRepository {
  const PersistingAuthRepository({
    required AuthRepository networkRepository,
    required TokenStorage tokenStorage,
  }) : _networkRepository = networkRepository,
       _tokenStorage = tokenStorage;

  final AuthRepository _networkRepository;
  final TokenStorage _tokenStorage;

  @override
  Future<User> register({required String email, required String password}) {
    return _networkRepository.register(email: email, password: password);
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _networkRepository.login(
      email: email,
      password: password,
    );
    await _tokenStorage.saveTokens(tokens);
    return tokens;
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final tokens = await _networkRepository.refresh(refreshToken);
    await _tokenStorage.saveTokens(tokens);
    return tokens;
  }
}
