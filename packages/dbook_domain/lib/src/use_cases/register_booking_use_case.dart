import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class RegisterBookingUseCase {
  const RegisterBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<Booking> call({required int bookableId, required int seatId}) {
    return _repository.create(bookableId: bookableId, seatId: seatId);
  }
}
