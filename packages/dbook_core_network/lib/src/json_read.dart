/// Um objeto JSON como o Dio o entrega.
typedef Json = Map<String, dynamic>;

/// Leitura tolerante do JSON do backend: campo ausente ou de tipo inesperado
/// não derruba a tela (cai num valor neutro), ao contrário de um cast que
/// lança. O servidor é o dono do contrato; o app só o lê.
extension JsonRead on Json {
  String? str(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  String text(String key) => str(key) ?? '';

  int? integer(String key) {
    final value = this[key];
    return value is num ? value.toInt() : null;
  }

  int count(String key) => integer(key) ?? 0;

  double? decimal(String key) {
    final value = this[key];
    return value is num ? value.toDouble() : null;
  }

  bool flag(String key, {bool fallback = false}) {
    final value = this[key];
    return value is bool ? value : fallback;
  }

  DateTime? time(String key) {
    final value = this[key];
    return value is String ? DateTime.tryParse(value) : null;
  }

  Json? obj(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  List<T> list<T>(String key, T Function(Json json) parse) {
    final value = this[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) parse(item),
    ];
  }

  List<String> strings(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String) item,
    ];
  }
}
