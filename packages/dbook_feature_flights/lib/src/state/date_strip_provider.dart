import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flight_providers.dart';

const dateStripRadius = 2;

/// Chave do [dateStripProvider] — rota + data central da faixa.
class DateStripQuery {
  const DateStripQuery({
    required this.originIataCode,
    required this.destinationIataCode,
    required this.centerDate,
  });

  final String originIataCode;
  final String destinationIataCode;
  final DateTime centerDate;

  @override
  bool operator ==(Object other) =>
      other is DateStripQuery &&
      other.originIataCode == originIataCode &&
      other.destinationIataCode == destinationIataCode &&
      other.centerDate == centerDate;

  @override
  int get hashCode => Object.hash(originIataCode, destinationIataCode, centerDate);
}

/// Uma data da faixa e o menor preço real encontrado nela (ou `null` — sem
/// voo nesse dia, não é erro).
class DateOption {
  const DateOption({required this.date, this.lowestPrice});

  final DateTime date;
  final double? lowestPrice;
}

/// Faixa de datas ao redor de [DateStripQuery.centerDate] (±2 dias) com o
/// menor preço real de cada uma — uma busca (`GET /flights/search`) por
/// data, igual ao que o card principal já faz pra data única, nunca preço
/// inventado. Usada pela faixa horizontal de datas dos Resultados.
final dateStripProvider = FutureProvider.autoDispose
    .family<List<DateOption>, DateStripQuery>((ref, query) async {
      final repository = ref.watch(flightRepositoryProvider);
      final base = DateTime(
        query.centerDate.year,
        query.centerDate.month,
        query.centerDate.day,
      );
      final dates = [
        for (var offset = -dateStripRadius; offset <= dateStripRadius; offset++)
          base.add(Duration(days: offset)),
      ];

      return Future.wait(
        dates.map((date) async {
          final flights = await repository.search(
            originIataCode: query.originIataCode,
            destinationIataCode: query.destinationIataCode,
            date: date,
          );
          if (flights.isEmpty) return DateOption(date: date);
          final lowestPrice = flights
              .map((flight) => flight.price)
              .reduce((a, b) => a < b ? a : b);
          return DateOption(date: date, lowestPrice: lowestPrice);
        }),
      );
    });
