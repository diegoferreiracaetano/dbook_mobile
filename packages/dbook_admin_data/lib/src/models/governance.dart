import '../json.dart';

/// A fila de moderação de avaliações.
enum ReviewQueue { reported, hidden, visible }

String reviewQueueToWire(ReviewQueue queue) => switch (queue) {
  ReviewQueue.reported => 'REPORTED',
  ReviewQueue.hidden => 'HIDDEN',
  ReviewQueue.visible => 'VISIBLE',
};

class AdminReview {
  const AdminReview({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.destination,
    required this.rating,
    required this.comment,
    required this.hidden,
    required this.openReports,
    this.hiddenReason,
    this.lastReportReason,
    this.createdAt,
  });

  factory AdminReview.fromJson(Json json) => AdminReview(
    id: json.count('id'),
    bookingId: json.count('bookingId'),
    customerId: json.count('customerId'),
    customerName: json.text('customerName'),
    destination: json.text('destination'),
    rating: json.count('rating'),
    comment: json.text('comment'),
    hidden: json.text('status') == 'HIDDEN',
    hiddenReason: json.str('hiddenReason'),
    openReports: json.count('openReports'),
    lastReportReason: json.str('lastReportReason'),
    createdAt: json.time('createdAt'),
  );

  final int id;
  final int bookingId;
  final int customerId;
  final String customerName;
  final String destination;
  final int rating;
  final String comment;
  final bool hidden;
  final String? hiddenReason;
  final int openReports;
  final String? lastReportReason;
  final DateTime? createdAt;
}

enum PromoType { percent, fixed, unknown }

PromoType promoTypeFromWire(String value) => switch (value) {
  'PERCENT' => PromoType.percent,
  'FIXED' => PromoType.fixed,
  _ => PromoType.unknown,
};

String promoTypeToWire(PromoType type) =>
    type == PromoType.percent ? 'PERCENT' : 'FIXED';

typedef PromoQuery = ({bool? active, int page, int size});

class Promo {
  const Promo({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minAmount,
    required this.maxPerUser,
    required this.redeemed,
    required this.active,
    this.validFrom,
    this.validUntil,
    this.maxRedemptions,
  });

  factory Promo.fromJson(Json json) => Promo(
    id: json.count('id'),
    code: json.text('code'),
    type: promoTypeFromWire(json.text('type')),
    value: json.decimal('value') ?? 0,
    minAmount: json.decimal('minAmount') ?? 0,
    validFrom: json.time('validFrom'),
    validUntil: json.time('validUntil'),
    maxRedemptions: json.integer('maxRedemptions'),
    maxPerUser: json.integer('maxPerUser') ?? 1,
    redeemed: json.count('redeemed'),
    active: json.flag('active'),
  );

  final int id;
  final String code;
  final PromoType type;
  final double value;
  final double minAmount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? maxRedemptions;
  final int maxPerUser;
  final int redeemed;
  final bool active;
}

/// Os campos de um código. Na edição só mudam o mínimo, a janela e os
/// limites (o código, o tipo e o valor nunca mudam).
class PromoForm {
  const PromoForm({
    required this.code,
    required this.type,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    this.minAmount,
    this.maxRedemptions,
    this.maxPerUser,
  });

  final String code;
  final PromoType type;
  final double value;
  final double? minAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? maxRedemptions;
  final int? maxPerUser;

  Map<String, Object?> createJson() => {
    'code': code.trim().toUpperCase(),
    'type': promoTypeToWire(type),
    'value': value,
    if (minAmount != null) 'minAmount': minAmount,
    'validFrom': validFrom.toUtc().toIso8601String(),
    'validUntil': validUntil.toUtc().toIso8601String(),
    if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
    if (maxPerUser != null) 'maxPerUser': maxPerUser,
  };

  Map<String, Object?> updateJson() => {
    if (minAmount != null) 'minAmount': minAmount,
    'validFrom': validFrom.toUtc().toIso8601String(),
    'validUntil': validUntil.toUtc().toIso8601String(),
    if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
    if (maxPerUser != null) 'maxPerUser': maxPerUser,
  };
}

class PromoRedemption {
  const PromoRedemption({
    required this.userId,
    required this.userName,
    required this.paymentId,
    required this.discount,
    this.createdAt,
  });

  factory PromoRedemption.fromJson(Json json) => PromoRedemption(
    userId: json.count('userId'),
    userName: json.text('userName'),
    paymentId: json.count('paymentId'),
    discount: json.decimal('discount') ?? 0,
    createdAt: json.time('createdAt'),
  );

  final int userId;
  final String userName;
  final int paymentId;
  final double discount;
  final DateTime? createdAt;
}
