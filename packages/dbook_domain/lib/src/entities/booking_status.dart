/// Estado de uma reserva — espelha `BookingStatus` do backend. Transição é
/// de mão única: `pending` vira `confirmed` OU `cancelled`, nunca volta.
enum BookingStatus { pending, confirmed, cancelled }
