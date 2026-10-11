import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dio/dio.dart';

/// Um objeto JSON como o Dio o entrega.
typedef Json = Map<String, dynamic>;

/// Leitura tolerante do JSON do backend: um campo ausente ou de tipo
/// inesperado não derruba a tela (o portal mostra "—"), ao contrário de um
/// cast que lança. O servidor é o dono do contrato; o portal só o lê.
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

  /// Instante ISO-8601. O backend manda horários de voo **sem fuso**
  /// (`2026-10-01T08:00:00`): ficam como estão, sem conversão.
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

/// Executa uma chamada e traduz o [DioException] no erro tipado do DBook
/// (com `code` e `retryAfter`). Toda chamada do portal passa por aqui.
Future<T> guarded<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw mapDioException(error);
  }
}

/// O corpo de uma resposta que deve ser um objeto.
Json bodyOf(Response<dynamic> response) {
  final data = response.data;
  return data is Map<String, dynamic> ? data : <String, dynamic>{};
}

/// Remove do mapa os valores nulos e as strings vazias (filtro não preenchido
/// não vai para a query string).
Map<String, dynamic> compact(Map<String, Object?> params) => {
  for (final entry in params.entries)
    if (entry.value != null && entry.value != '') entry.key: entry.value,
};
