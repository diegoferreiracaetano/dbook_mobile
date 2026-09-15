import '../entities/payment.dart';

/// Porta pro pagamento de reservas — porta própria em vez de um método a
/// mais em `BookingRepository` porque espelha 1:1 o `PaymentController`
/// do backend (mesmo padrão de "um port por controller" do projeto).
abstract interface class PaymentRepository {
  /// `POST /payments` — paga uma ou mais reservas PENDING do usuário
  /// autenticado de uma vez (ex. ida + volta de uma Round Trip), sem
  /// nunca enviar o número completo do cartão ou o CVV — só os 4 últimos
  /// dígitos e o nome do titular.
  Future<Payment> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
  });
}
