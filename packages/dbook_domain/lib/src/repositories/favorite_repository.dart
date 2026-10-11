/// Porta dos favoritos de destino do usuário (`/v1/favorites`). **O servidor
/// é a fonte da verdade**: o que o aparelho guarda é só cache de leitura.
abstract interface class FavoriteRepository {
  /// Os códigos IATA dos destinos favoritos (todas as páginas).
  Future<Set<String>> destinations();

  /// Salva. Idempotente (`204` mesmo se já era favorito). `404` se o destino
  /// não existe e `409` com `code=FAVORITES_LIMIT` no 201º.
  Future<void> addDestination(String iataCode);

  /// Remove. Idempotente.
  Future<void> removeDestination(String iataCode);
}
