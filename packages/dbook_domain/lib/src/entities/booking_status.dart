/// Estado de uma reserva — espelha `BookingStatus` do backend. Transição é
/// de mão única: `pending` vira `confirmed` OU `cancelled`, nunca volta.
/// unknown: um valor que o servidor mandou e este app ainda não conhece.
enum BookingStatus { pending, confirmed, cancelled, unknown }
