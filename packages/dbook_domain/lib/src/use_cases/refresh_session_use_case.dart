import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call(String refreshToken) {
    return _repository.refresh(refreshToken);
  }
}
