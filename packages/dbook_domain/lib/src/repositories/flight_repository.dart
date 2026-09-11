import '../entities/flight.dart';
import '../entities/seat.dart';

/// Porta pro acesso a voos e assentos — implementada de verdade em
/// `dbook_core_network`, com um fake em memória nos testes de use case.
abstract interface class FlightRepository {
  /// `GET /flights/search?origin=&destination=&date=`
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  });

  /// `GET /bookables/{id}/seats`
  Future<List<Seat>> getSeats(int bookableId);
}
