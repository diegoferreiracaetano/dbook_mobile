import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

/// Os filtros da lista de reservas; é a chave do provider e o que a URL guarda.
typedef AdminBookingQuery = ({
  BookingStatus? status,
  int? bookableId,
  int? customerId,
  DateTime? from,
  DateTime? to,
  bool? paid,
  int page,
  int size,
});

const AdminBookingQuery defaultBookingQuery = (
  status: null,
  bookableId: null,
  customerId: null,
  from: null,
  to: null,
  paid: null,
  page: 0,
  size: 20,
);

String bookingStatusToWire(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'PENDING',
  BookingStatus.confirmed => 'CONFIRMED',
  BookingStatus.cancelled => 'CANCELLED',
  BookingStatus.expired => 'EXPIRED',
  BookingStatus.refunded => 'REFUNDED',
  BookingStatus.unknown => 'UNKNOWN',
};

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.status,
    required this.price,
    required this.title,
    required this.customerId,
    required this.customerName,
    this.createdAt,
    this.bookableId,
    this.seatLabel,
    this.flightNumber,
    this.origin,
    this.destination,
    this.departureTime,
    this.paymentId,
    this.discount,
    this.paidAmount,
  });

  factory AdminBooking.fromJson(Json json) => AdminBooking(
    id: json.count('id'),
    status: bookingStatusFromWire(json.text('status')),
    price: json.decimal('price') ?? 0,
    title: json.text('title'),
    customerId: json.count('customerId'),
    customerName: json.text('customerName'),
    createdAt: json.time('createdAt'),
    bookableId: json.integer('bookableId'),
    seatLabel: json.str('seatLabel'),
    flightNumber: json.str('flightNumber'),
    origin: json.str('origin'),
    destination: json.str('destination'),
    departureTime: json.time('departureTime'),
    paymentId: json.integer('paymentId'),
    discount: json.decimal('discount'),
    paidAmount: json.decimal('paidAmount'),
  );

  final int id;
  final BookingStatus status;

  /// O valor **congelado** na reserva (não o preço atual do voo).
  final double price;
  final String title;
  final int customerId;
  final String customerName;
  final DateTime? createdAt;
  final int? bookableId;
  final String? seatLabel;
  final String? flightNumber;
  final String? origin;
  final String? destination;
  final DateTime? departureTime;
  final int? paymentId;
  final double? discount;
  final double? paidAmount;

  bool get isPaid => paymentId != null;
  String? get route =>
      origin != null && destination != null ? '$origin → $destination' : null;
}

class PaymentInfo {
  const PaymentInfo({
    required this.id,
    required this.amount,
    required this.cardLast4,
    this.createdAt,
  });

  factory PaymentInfo.fromJson(Json json) => PaymentInfo(
    id: json.count('id'),
    amount: json.decimal('amount') ?? 0,
    cardLast4: json.text('cardLast4'),
    createdAt: json.time('createdAt'),
  );

  final int id;
  final double amount;
  final String cardLast4;
  final DateTime? createdAt;
}

enum RefundStatus { requested, completed, failed, unknown }

RefundStatus refundStatusFromWire(String value) => switch (value) {
  'REQUESTED' => RefundStatus.requested,
  'COMPLETED' => RefundStatus.completed,
  'FAILED' => RefundStatus.failed,
  _ => () {
    onUnknownWireValue('RefundStatus', value);
    return RefundStatus.unknown;
  }(),
};

String refundStatusToWire(RefundStatus status) => switch (status) {
  RefundStatus.requested => 'REQUESTED',
  RefundStatus.completed => 'COMPLETED',
  RefundStatus.failed => 'FAILED',
  RefundStatus.unknown => 'UNKNOWN',
};

enum RefundReason { customerRequest, flightCancelled, duplicate, other }

String refundReasonToWire(RefundReason reason) => switch (reason) {
  RefundReason.customerRequest => 'CUSTOMER_REQUEST',
  RefundReason.flightCancelled => 'FLIGHT_CANCELLED',
  RefundReason.duplicate => 'DUPLICATE',
  RefundReason.other => 'OTHER',
};

RefundReason? refundReasonFromWire(String? value) => switch (value) {
  'CUSTOMER_REQUEST' => RefundReason.customerRequest,
  'FLIGHT_CANCELLED' => RefundReason.flightCancelled,
  'DUPLICATE' => RefundReason.duplicate,
  'OTHER' => RefundReason.other,
  _ => null,
};

class Refund {
  const Refund({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.status,
    this.paymentId,
    this.reason,
    this.failureReason,
    this.requestedBy,
    this.createdAt,
    this.completedAt,
  });

  factory Refund.fromJson(Json json) => Refund(
    id: json.count('id'),
    bookingId: json.count('bookingId'),
    amount: json.decimal('amount') ?? 0,
    status: refundStatusFromWire(json.text('status')),
    paymentId: json.integer('paymentId'),
    reason: refundReasonFromWire(json.str('reason')),
    failureReason: json.str('failureReason'),
    requestedBy: json.integer('requestedBy'),
    createdAt: json.time('createdAt'),
    completedAt: json.time('completedAt'),
  );

  final int id;
  final int bookingId;
  final int? paymentId;
  final double amount;
  final RefundReason? reason;
  final RefundStatus status;
  final String? failureReason;
  final int? requestedBy;
  final DateTime? createdAt;
  final DateTime? completedAt;

  /// Falhou, ou a queda deixou "pedido" sem terminar: dá para tentar de novo.
  bool get canRetry =>
      status == RefundStatus.failed || status == RefundStatus.requested;
}

/// Um degrau da linha do tempo da reserva. [from] é `null` na criação e
/// [actorId] é `null` quando foi o sistema (a expiração).
class TimelineEntry {
  const TimelineEntry({this.from, this.to, this.actorId, this.occurredAt});

  factory TimelineEntry.fromJson(Json json) => TimelineEntry(
    from: json.str('from') == null
        ? null
        : bookingStatusFromWire(json.text('from')),
    to: json.str('to') == null ? null : bookingStatusFromWire(json.text('to')),
    actorId: json.integer('actorId'),
    occurredAt: json.time('occurredAt'),
  );

  final BookingStatus? from;
  final BookingStatus? to;
  final int? actorId;
  final DateTime? occurredAt;
}

class AdminBookingDetail {
  const AdminBookingDetail({
    required this.booking,
    required this.timeline,
    this.payment,
    this.refund,
  });

  factory AdminBookingDetail.fromJson(Json json) => AdminBookingDetail(
    booking: AdminBooking.fromJson(json.obj('booking') ?? const {}),
    payment: json.obj('payment') == null
        ? null
        : PaymentInfo.fromJson(json.obj('payment')!),
    refund: json.obj('refund') == null
        ? null
        : Refund.fromJson(json.obj('refund')!),
    timeline: json.list('timeline', TimelineEntry.fromJson),
  );

  final AdminBooking booking;
  final PaymentInfo? payment;
  final Refund? refund;
  final List<TimelineEntry> timeline;
}

/// O pedido de reembolso; o `override` (exceção de política) exige [note] e
/// só vale para `SUPER_ADMIN`.
class RefundRequest {
  const RefundRequest({required this.reason, this.note, this.override = false});

  final RefundReason reason;
  final String? note;
  final bool override;

  /// A "impressão digital" do pedido: se mudar, é **outra tentativa** e leva
  /// outra chave de idempotência; se for a mesma, repete a chave.
  String get fingerprint =>
      '${refundReasonToWire(reason)}|${note ?? ''}|$override';
}

typedef RefundQuery = ({RefundStatus? status, int page, int size});
