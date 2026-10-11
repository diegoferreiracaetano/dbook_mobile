import 'package:flutter/painting.dart';

/// Cores **categóricas**: distinguem coisas que não têm significado de
/// estado (uma companhia aérea de outra, uma série de outra num gráfico).
/// Não são cor de marca nem de status; por isso moram à parte do
/// [DbookPalette]. Todas têm contraste AA com texto branco por cima.
abstract final class DbookCategoricalColors {
  static const List<Color> series = [
    Color(0xFFB23A2E),
    Color(0xFF1E4FA3),
    Color(0xFF1E7A34),
    Color(0xFF6A3FA0),
    Color(0xFFB35A00),
    Color(0xFF00838F),
  ];

  /// Cores de companhias conhecidas; as demais caem em [forKey].
  static const Map<String, Color> airlines = {
    'LA': Color(0xFFB23A2E),
    'AD': Color(0xFF1E4FA3),
    'G3': Color(0xFF1E7A34),
    'AA': Color(0xFF6A3FA0),
    'DL': Color(0xFFB35A00),
    'UA': Color(0xFF00838F),
  };

  /// Cor estável para qualquer chave: a conhecida pela tabela, as demais
  /// por hash (determinístico, sem a garantia de distinção da tabela).
  static Color forKey(String key) =>
      airlines[key] ?? series[key.hashCode.abs() % series.length];

  /// Véu escuro sobre foto, para texto branco legível por cima.
  static const List<Color> photoScrim = [Color(0x00000000), Color(0xCC000000)];
}
