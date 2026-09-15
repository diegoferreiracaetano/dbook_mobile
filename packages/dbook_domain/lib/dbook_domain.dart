/// Domínio do DBook — entidades, portas e casos de uso. Dart puro, sem
/// Flutter: as camadas de feature dependem daqui, nunca o contrário.
library;

export 'src/entities/ai_suggestion.dart';
export 'src/entities/auth_tokens.dart';
export 'src/entities/booking.dart';
export 'src/entities/booking_status.dart';
export 'src/entities/destination.dart';
export 'src/entities/flight.dart';
export 'src/entities/my_booking.dart';
export 'src/entities/payment.dart';
export 'src/entities/role.dart';
export 'src/entities/seat.dart';
export 'src/entities/seat_class.dart';
export 'src/entities/seat_status.dart';
export 'src/entities/user.dart';
export 'src/repositories/ai_suggestion_repository.dart';
export 'src/repositories/auth_repository.dart';
export 'src/repositories/booking_repository.dart';
export 'src/repositories/destination_repository.dart';
export 'src/repositories/flight_repository.dart';
export 'src/repositories/payment_repository.dart';
export 'src/use_cases/cancel_booking_use_case.dart';
export 'src/use_cases/get_seats_use_case.dart';
export 'src/use_cases/login_use_case.dart';
export 'src/use_cases/refresh_session_use_case.dart';
export 'src/use_cases/register_booking_use_case.dart';
export 'src/use_cases/register_use_case.dart';
export 'src/use_cases/search_flights_use_case.dart';
export 'src/use_cases/suggest_flights_use_case.dart';
