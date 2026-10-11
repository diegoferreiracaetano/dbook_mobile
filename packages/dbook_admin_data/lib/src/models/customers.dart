import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

enum CustomerStatus { active, blocked, unknown }

CustomerStatus customerStatusFromWire(String value) => switch (value) {
  'ACTIVE' => CustomerStatus.active,
  'BLOCKED' => CustomerStatus.blocked,
  _ => () {
    onUnknownWireValue('CustomerStatus', value);
    return CustomerStatus.unknown;
  }(),
};

enum CustomerSort { name, email, createdAt, lastLoginAt }

extension on CustomerSort {
  String get wire => switch (this) {
    CustomerSort.name => 'NAME',
    CustomerSort.email => 'EMAIL',
    CustomerSort.createdAt => 'CREATED_AT',
    CustomerSort.lastLoginAt => 'LAST_LOGIN_AT',
  };
}

/// A consulta da lista de clientes. É a **chave** do provider da lista e o que
/// a URL guarda: dois valores iguais são a mesma consulta (os records Dart
/// comparam por valor).
typedef CustomerQuery = ({
  String text,
  CustomerStatus? status,
  DateTime? from,
  DateTime? to,
  bool? hasBookings,
  CustomerSort sort,
  bool descending,
  int page,
  int size,
});

const CustomerQuery defaultCustomerQuery = (
  text: '',
  status: null,
  from: null,
  to: null,
  hasBookings: null,
  sort: CustomerSort.createdAt,
  descending: true,
  page: 0,
  size: 20,
);

String customerSortWire(CustomerSort sort) => sort.wire;

class CustomerSummary {
  const CustomerSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.bookingCount,
    this.createdAt,
    this.lastLoginAt,
  });

  factory CustomerSummary.fromJson(Json json) => CustomerSummary(
    id: json.count('id'),
    name: json.text('name'),
    email: json.text('email'),
    status: customerStatusFromWire(json.text('status')),
    bookingCount: json.count('bookingCount'),
    createdAt: json.time('createdAt'),
    lastLoginAt: json.time('lastLoginAt'),
  );

  final int id;
  final String name;
  final String email;
  final CustomerStatus status;
  final int bookingCount;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
}

class BookingTotals {
  const BookingTotals({
    this.total = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.cancelled = 0,
  });

  factory BookingTotals.fromJson(Json? json) => json == null
      ? const BookingTotals()
      : BookingTotals(
          total: json.count('total'),
          pending: json.count('pending'),
          confirmed: json.count('confirmed'),
          cancelled: json.count('cancelled'),
        );

  final int total;
  final int pending;
  final int confirmed;
  final int cancelled;
}

/// A visão 360º de um cliente (`GET /v1/admin/customers/{id}`).
class CustomerDetail {
  const CustomerDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.bookings,
    required this.paymentCount,
    required this.reviewCount,
    this.blockedReason,
    this.blockedAt,
    this.createdAt,
    this.lastLoginAt,
    this.anonymizedAt,
    this.totalPaid,
    this.averageRating,
  });

  factory CustomerDetail.fromJson(Json json) => CustomerDetail(
    id: json.count('id'),
    name: json.text('name'),
    email: json.text('email'),
    status: customerStatusFromWire(json.text('status')),
    blockedReason: json.str('blockedReason'),
    blockedAt: json.time('blockedAt'),
    createdAt: json.time('createdAt'),
    lastLoginAt: json.time('lastLoginAt'),
    anonymizedAt: json.time('anonymizedAt'),
    bookings: BookingTotals.fromJson(json.obj('bookings')),
    paymentCount: json.obj('payments')?.count('count') ?? 0,
    totalPaid: json.obj('payments')?.decimal('totalPaid'),
    reviewCount: json.obj('reviews')?.count('count') ?? 0,
    averageRating: json.obj('reviews')?.decimal('averageRating'),
  );

  final int id;
  final String name;
  final String email;
  final CustomerStatus status;
  final String? blockedReason;
  final DateTime? blockedAt;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final DateTime? anonymizedAt;
  final BookingTotals bookings;
  final int paymentCount;
  final double? totalPaid;
  final int reviewCount;
  final double? averageRating;

  bool get isBlocked => status == CustomerStatus.blocked;
  bool get isAnonymized => anonymizedAt != null;
}

class CustomerBooking {
  const CustomerBooking({
    required this.id,
    required this.status,
    required this.price,
    required this.title,
    this.seatLabel,
    this.flightNumber,
    this.origin,
    this.destination,
    this.departureTime,
    this.paymentId,
  });

  factory CustomerBooking.fromJson(Json json) => CustomerBooking(
    id: json.count('id'),
    status: bookingStatusFromWire(json.text('status')),
    price: json.decimal('price') ?? 0,
    title: json.text('title'),
    seatLabel: json.str('seatLabel'),
    flightNumber: json.str('flightNumber'),
    origin: json.str('origin'),
    destination: json.str('destination'),
    departureTime: json.time('departureTime'),
    paymentId: json.integer('paymentId'),
  );

  final int id;
  final BookingStatus status;
  final double price;
  final String title;
  final String? seatLabel;
  final String? flightNumber;
  final String? origin;
  final String? destination;
  final DateTime? departureTime;
  final int? paymentId;
}

class CustomerPayment {
  const CustomerPayment({
    required this.id,
    required this.amount,
    required this.cardLast4,
    required this.bookingIds,
    this.createdAt,
  });

  factory CustomerPayment.fromJson(Json json) => CustomerPayment(
    id: json.count('id'),
    amount: json.decimal('amount') ?? 0,
    cardLast4: json.text('cardLast4'),
    createdAt: json.time('createdAt'),
    bookingIds: [
      for (final id in (json['bookingIds'] as List? ?? const []))
        if (id is num) id.toInt(),
    ],
  );

  final int id;
  final double amount;
  final String cardLast4;
  final DateTime? createdAt;
  final List<int> bookingIds;
}

class CustomerReview {
  const CustomerReview({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory CustomerReview.fromJson(Json json) => CustomerReview(
    id: json.count('id'),
    bookingId: json.count('bookingId'),
    rating: json.count('rating'),
    comment: json.text('comment'),
    createdAt: json.time('createdAt'),
  );

  final int id;
  final int bookingId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
}

class CustomerNote {
  const CustomerNote({
    required this.id,
    required this.authorId,
    required this.body,
    required this.pinned,
    this.createdAt,
    this.editedAt,
  });

  factory CustomerNote.fromJson(Json json) => CustomerNote(
    id: json.count('id'),
    authorId: json.count('authorId'),
    body: json.text('body'),
    pinned: json.flag('pinned'),
    createdAt: json.time('createdAt'),
    editedAt: json.time('editedAt'),
  );

  final int id;
  final int authorId;
  final String body;
  final bool pinned;
  final DateTime? createdAt;
  final DateTime? editedAt;
}

/// Resposta de bloquear, desbloquear e anonimizar.
class CustomerModeration {
  const CustomerModeration({
    required this.id,
    required this.status,
    this.blockedReason,
    this.blockedAt,
  });

  factory CustomerModeration.fromJson(Json json) => CustomerModeration(
    id: json.count('id'),
    status: customerStatusFromWire(json.text('status')),
    blockedReason: json.str('blockedReason'),
    blockedAt: json.time('blockedAt'),
  );

  final int id;
  final CustomerStatus status;
  final String? blockedReason;
  final DateTime? blockedAt;
}
