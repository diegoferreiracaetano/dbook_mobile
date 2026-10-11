/// Porta da privacidade do próprio cliente (LGPD): exportar o que o sistema
/// guarda sobre ele e excluir (anonimizar) a conta.
abstract interface class PrivacyRepository {
  /// `GET /v1/users/me/export`: perfil, reservas, pagamentos e avaliações de
  /// quem pede, como o servidor os devolve.
  Future<Map<String, dynamic>> exportMyData();

  /// `DELETE /v1/users/me` com a senha. Anonimiza a conta e encerra todas as
  /// sessões; **não se desfaz**. `401` com a senha errada (conta dentro do
  /// limite de tentativas de login), `409` para conta de equipe.
  Future<void> deleteMyAccount({required String password});
}
