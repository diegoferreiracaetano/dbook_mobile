import '../entities/payment.dart';

/// Porta pro pagamento de reservas — porta própria em vez de um método a
/// mais em `BookingRepository` porque espelha 1:1 o `PaymentController`
/// do backend (mesmo padrão de "um port por controller" do projeto).
abstract interface class PaymentRepository {
  /// `POST /payments` — paga uma ou mais reservas PENDING do usuário
  /// autenticado de uma vez (ex. ida + volta de uma Round Trip), sem
  /// nunca enviar o número completo do cartão ou o CVV — só os 4 últimos
  /// dígitos e o nome do titular.
  ///
  /// [idempotencyKey] vai no header `Idempotency-Key`: se a resposta se
  /// perder e o pedido for repetido com a mesma chave, o backend devolve o
  /// pagamento original em vez de cobrar duas vezes. Uma chave por tentativa
  /// de pagamento — quem gera e reaproveita é o `PaymentNotifier`.
  ///
  /// [promoCode] (opcional) faz parte do pedido: o desconto é decidido, de
  /// forma atômica, ao pagar (`422 PROMO_REJECTED` desfaz tudo e as reservas
  /// seguem pendentes).
  Future<Payment> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
    required String idempotencyKey,
    String? promoCode,
  });
}
