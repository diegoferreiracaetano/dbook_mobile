import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

class SearchFlightsUseCase {
  const SearchFlightsUseCase(this._repository);

  final FlightRepository _repository;

  Future<List<Flight>> call({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) {
    return _repository.search(
      originIataCode: originIataCode,
      destinationIataCode: destinationIataCode,
      date: date,
    );
  }
}
