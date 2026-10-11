import '../entities/price_tracking.dart';

/// Porta do histórico de preço (público) e dos alertas do usuário.
abstract interface class PriceRepository {
  Future<PriceHistory> history(int flightId);

  Future<List<PriceAlert>> alerts();

  /// `409` para um segundo alerta da mesma rota e data, ou com
  /// `code=PRICE_ALERTS_LIMIT` no 21º ativo; `404` aeroporto inexistente.
  Future<PriceAlert> createAlert({
    required String origin,
    required String destination,
    required DateTime date,
    required double targetPrice,
  });

  /// Muda o alvo e/ou liga e desliga. Mudar o alvo zera a janela de 24 h.
  Future<PriceAlert> updateAlert(int id, {double? targetPrice, bool? active});

  Future<void> deleteAlert(int id);
}
