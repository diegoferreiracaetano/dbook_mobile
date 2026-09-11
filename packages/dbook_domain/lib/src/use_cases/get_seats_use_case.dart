import '../entities/seat.dart';
import '../repositories/flight_repository.dart';

class GetSeatsUseCase {
  const GetSeatsUseCase(this._repository);

  final FlightRepository _repository;

  Future<List<Seat>> call(int bookableId) => _repository.getSeats(bookableId);
}
