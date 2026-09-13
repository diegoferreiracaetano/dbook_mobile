import 'package:freezed_annotation/freezed_annotation.dart';

import 'seat_class.dart';

part 'flight.freezed.dart';

/// Voo — espelha `FlightResponse` do backend (não a entidade `Flight` do
/// domínio do backend, que aninha `Airport` completo). `GET /flights/search`
/// só devolve o código IATA de origem/destino, não o `Airport` inteiro, e é
/// esse contrato de fio que o app de verdade recebe.
@freezed
abstract class Flight with _$Flight {
  const factory Flight({
    required int id,
    required String flightNumber,
    required String airlineIataCode,
    required String airlineName,
    required String originIataCode,
    required String destinationIataCode,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required SeatClass seatClass,
    required double price,
    required int availableCapacity,
  }) = _Flight;
}
