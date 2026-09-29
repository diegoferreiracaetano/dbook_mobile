import '../entities/review.dart';

/// Porta pra avaliação de reservas.
abstract interface class ReviewRepository {
  /// `POST /reviews` — `customerId` vem do JWT no backend, não é passado
  /// aqui. Só funciona se a reserva já estiver CONFIRMED e ainda não
  /// tiver sido avaliada (o backend recusa com 409 caso contrário).
  Future<Review> create({
    required int bookingId,
    required int rating,
    required String comment,
  });
}
