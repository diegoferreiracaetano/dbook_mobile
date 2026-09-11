import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(int bookingId) => _repository.cancel(bookingId);
}
