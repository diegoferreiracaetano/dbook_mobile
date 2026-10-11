/// A prévia de um código promocional sobre as reservas a pagar
/// (`POST /v1/promo-codes/validate`): o desconto que **seria** aplicado, sem
/// gastar o código. Não promete que o código ainda estará disponível na hora
/// de pagar: isso se decide, de forma atômica, no pagamento.
class PromoPreview {
  const PromoPreview({
    required this.code,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final String code;
  final double subtotal;
  final double discount;
  final double total;
}
