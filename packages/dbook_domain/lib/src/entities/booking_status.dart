/// Estado de uma reserva — espelha `BookingStatus` do backend. `pending` vira
/// `confirmed`, `cancelled` ou `expired` (a fila de expiração); `confirmed`
/// pode virar `refunded`.
/// unknown: um valor que o servidor mandou e este app ainda não conhece.
enum BookingStatus { pending, confirmed, cancelled, expired, refunded, unknown }
