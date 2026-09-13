import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  final json = {
    'id': 1,
    'flightNumber': 'IB 6821',
    'airlineIataCode': 'IB',
    'airlineName': 'Iberia',
    'origin': 'GRU',
    'destination': 'MAD',
    'departureTime': '2026-01-13T10:30:00',
    'arrivalTime': '2026-01-14T06:45:00',
    'seatClass': 'ECONOMY',
    'price': 450.0,
    'availableCapacity': 42,
  };

  test('given the API JSON when parsed then every field maps correctly', () {
    final dto = FlightResponseDto.fromJson(json);

    expect(dto.id, 1);
    expect(dto.origin, 'GRU');
    expect(dto.seatClass, 'ECONOMY');
    expect(dto.price, 450.0);
  });

  test('given a parsed DTO when converted to domain then IATA codes and enum '
      'map correctly', () {
    final flight = FlightResponseDto.fromJson(json).toDomain();

    expect(flight.originIataCode, 'GRU');
    expect(flight.destinationIataCode, 'MAD');
    expect(flight.seatClass, SeatClass.economy);
    expect(flight.departureTime, DateTime.parse('2026-01-13T10:30:00'));
  });
}
