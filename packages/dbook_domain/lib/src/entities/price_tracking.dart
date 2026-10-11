/// Um ponto do histórico: o preço que o voo passou a ter em [changedAt].
class PricePoint {
  const PricePoint({required this.price, required this.changedAt});

  final double price;
  final DateTime changedAt;
}

/// Como o preço de um voo se moveu (`GET /v1/flights/{id}/price-history`):
/// do mais antigo ao mais novo, no máximo os 500 mais recentes.
class PriceHistory {
  const PriceHistory({
    required this.flightId,
    required this.current,
    required this.lowest,
    required this.highest,
    required this.points,
  });

  final int flightId;
  final double current;
  final double lowest;
  final double highest;
  final List<PricePoint> points;

  /// A média dos preços que o voo já teve. É conta da tela sobre o que o
  /// servidor mandou (o servidor não publica média).
  double? get average => points.isEmpty
      ? null
      : points.fold<double>(0, (sum, p) => sum + p.price) / points.length;

  /// O preço de agora contra a média: `below` (abaixo), `above` (acima) ou
  /// `same`. Sem histórico para comparar, `same`.
  PriceTrend get trend {
    final mean = average;
    if (mean == null || points.length < 2) return PriceTrend.same;
    if (current < mean - 0.005) return PriceTrend.below;
    if (current > mean + 0.005) return PriceTrend.above;
    return PriceTrend.same;
  }
}

enum PriceTrend { below, above, same }

/// Um alerta: "avise quando um voo desta rota e data custar até [targetPrice]".
class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.targetPrice,
    required this.active,
    this.lastNotifiedAt,
  });

  final int id;
  final String origin;
  final String destination;

  /// Só a data (a hora não conta).
  final DateTime date;
  final double targetPrice;
  final bool active;
  final DateTime? lastNotifiedAt;

  PriceAlert copyWith({double? targetPrice, bool? active}) => PriceAlert(
    id: id,
    origin: origin,
    destination: destination,
    date: date,
    targetPrice: targetPrice ?? this.targetPrice,
    active: active ?? this.active,
    lastNotifiedAt: lastNotifiedAt,
  );
}
