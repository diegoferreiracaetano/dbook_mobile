import 'package:dbook_domain/dbook_domain.dart';

/// Os enums do domínio são Dart puro (sem `json_serializable`, de
/// propósito — serialização é preocupação de `dbook_core_network`, não do
/// domínio). Essas funções traduzem o valor de fio (`UPPER_SNAKE_CASE`,
/// igual ao nome do enum Kotlin no backend) pro enum Dart correspondente.
Role roleFromWire(String value) => switch (value) {
  'ADMIN' => Role.admin,
  'CLIENT' => Role.client,
  _ => throw FormatException('Unknown Role from API: $value'),
};

SeatClass seatClassFromWire(String value) => switch (value) {
  'ECONOMY' => SeatClass.economy,
  'PREMIUM_ECONOMY' => SeatClass.premiumEconomy,
  'BUSINESS' => SeatClass.business,
  'FIRST' => SeatClass.first,
  _ => throw FormatException('Unknown SeatClass from API: $value'),
};

SeatStatus seatStatusFromWire(String value) => switch (value) {
  'AVAILABLE' => SeatStatus.available,
  'RESERVED' => SeatStatus.reserved,
  _ => throw FormatException('Unknown SeatStatus from API: $value'),
};

BookingStatus bookingStatusFromWire(String value) => switch (value) {
  'PENDING' => BookingStatus.pending,
  'CONFIRMED' => BookingStatus.confirmed,
  'CANCELLED' => BookingStatus.cancelled,
  _ => throw FormatException('Unknown BookingStatus from API: $value'),
};
