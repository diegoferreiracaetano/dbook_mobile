import 'dart:convert';

import 'package:dbook_domain/dbook_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'recent_stay_searches';
const _max = 4;

/// Uma busca de hotel já feita, guardada no aparelho para refazer com um
/// toque. É conveniência da tela (como o histórico de um navegador), não dado
/// de negócio: nada daqui vai ao servidor nem decide o que o cliente pode.
class RecentStaySearch {
  const RecentStaySearch({
    required this.destinationCode,
    required this.destinationLabel,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  factory RecentStaySearch.fromJson(Map<String, dynamic> json) =>
      RecentStaySearch(
        destinationCode: json['code'] as String,
        destinationLabel: json['label'] as String,
        checkIn: DateTime.parse(json['checkIn'] as String),
        checkOut: DateTime.parse(json['checkOut'] as String),
        guests: json['guests'] as int,
      );

  final String destinationCode;
  final String destinationLabel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  Map<String, dynamic> toJson() => {
    'code': destinationCode,
    'label': destinationLabel,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'guests': guests,
  };

  bool sameAs(RecentStaySearch other) =>
      destinationCode == other.destinationCode &&
      checkIn == other.checkIn &&
      checkOut == other.checkOut &&
      guests == other.guests;
}

/// Lê e grava as últimas buscas (as 4 mais recentes, sem repetição). Falha de
/// armazenamento nunca atrapalha a busca: devolve vazio ou ignora.
class RecentStaySearches {
  const RecentStaySearches._();

  static Future<List<RecentStaySearch>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? const [];
      return [
        for (final item in raw)
          RecentStaySearch.fromJson(jsonDecode(item) as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  static Future<List<RecentStaySearch>> add(
    Destination destination,
    StaySearch search,
  ) async {
    final entry = RecentStaySearch(
      destinationCode: destination.iataCode,
      destinationLabel: destination.city,
      checkIn: search.checkIn,
      checkOut: search.checkOut,
      guests: search.guests,
    );
    final current = await load();
    final next = [
      entry,
      ...current.where((e) => !e.sameAs(entry)),
    ].take(_max).toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, [
        for (final e in next) jsonEncode(e.toJson()),
      ]);
    } on Object {
      // sem armazenamento: o histórico só não persiste
    }
    return next;
  }
}
