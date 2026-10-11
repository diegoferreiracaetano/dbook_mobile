import '../entities/promo_preview.dart';

/// Porta para prever um código promocional antes de pagar.
abstract interface class PromoRepository {
  /// `404` se o código não existe; `422` com `code=PROMO_REJECTED` se existe
  /// mas não pode ser usado (vencido, esgotado, abaixo do mínimo, já usado).
  Future<PromoPreview> validate({
    required String code,
    required List<int> bookingIds,
  });
}
