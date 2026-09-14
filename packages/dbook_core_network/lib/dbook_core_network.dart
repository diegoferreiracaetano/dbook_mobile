/// Cliente HTTP, DTOs e implementações de repositório da API do DBook.
/// Implementa as portas de `dbook_domain` — nenhuma feature deve montar
/// `Dio` ou falar com a API direto.
library;

export 'src/dbook_dio_client.dart';
export 'src/dtos/ai_suggestion_item_dto.dart';
export 'src/dtos/booking_response_dto.dart';
export 'src/dtos/destination_response_dto.dart';
export 'src/dtos/flight_response_dto.dart';
export 'src/dtos/login_request_dto.dart';
export 'src/dtos/my_booking_response_dto.dart';
export 'src/dtos/refresh_request_dto.dart';
export 'src/dtos/register_booking_request_dto.dart';
export 'src/dtos/register_user_request_dto.dart';
export 'src/dtos/seat_response_dto.dart';
export 'src/dtos/suggest_flights_request_dto.dart';
export 'src/dtos/suggest_flights_response_dto.dart';
export 'src/dtos/token_response_dto.dart';
export 'src/dtos/update_user_name_request_dto.dart';
export 'src/dtos/user_response_dto.dart';
export 'src/exceptions/dbook_network_exception.dart';
export 'src/repositories/ai_suggestion_repository_impl.dart';
export 'src/repositories/auth_repository_impl.dart';
export 'src/repositories/booking_repository_impl.dart';
export 'src/repositories/destination_repository_impl.dart';
export 'src/repositories/flight_repository_impl.dart';
export 'src/wire_enums.dart';
