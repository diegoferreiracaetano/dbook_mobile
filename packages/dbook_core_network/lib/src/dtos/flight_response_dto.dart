import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../wire_enums.dart';

part 'flight_response_dto.freezed.dart';
part 'flight_response_dto.g.dart';

/// Item de `GET /flights/search` — `origin`/`destination` são código IATA
/// (`String`), não um `Airport` aninhado; `departureTime`/`arrivalTime` vêm
/// como `LocalDateTime` ISO-8601 sem timezone, exatamente como o Jackson do
/// backend serializa.
@freezed
abstract class FlightResponseDto with _$FlightResponseDto {
  const FlightResponseDto._();

  const factory FlightResponseDto({
    required int id,
    required String flightNumber,
    required String airlineIataCode,
    required String airlineName,
    required String origin,
    required String destination,
    required String departureTime,
    required String arrivalTime,
    required String seatClass,
    required double price,
    required int availableCapacity,
    required String aircraftType,
    required List<int> seatLayout,
  }) = _FlightResponseDto;

  factory FlightResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FlightResponseDtoFromJson(json);

  Flight toDomain() {
    return Flight(
      id: id,
      flightNumber: flightNumber,
      airlineIataCode: airlineIataCode,
      airlineName: airlineName,
      originIataCode: origin,
      destinationIataCode: destination,
      departureTime: DateTime.parse(departureTime),
      arrivalTime: DateTime.parse(arrivalTime),
      seatClass: seatClassFromWire(seatClass),
      price: price,
      availableCapacity: availableCapacity,
      aircraftType: aircraftType,
      seatLayout: seatLayout,
    );
  }
}
