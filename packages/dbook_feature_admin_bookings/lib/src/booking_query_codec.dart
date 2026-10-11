import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';

/// A consulta de reservas ↔ a *query string* da URL (só o que difere do
/// padrão vai para ela).
class BookingQueryCodec {
  const BookingQueryCodec._();

  static AdminBookingQuery decode(Map<String, String> params) => (
    status: BookingStatus.values.asNameMap()[params['status']],
    bookableId: int.tryParse(params['flight'] ?? ''),
    customerId: int.tryParse(params['customer'] ?? ''),
    from: DateTime.tryParse(params['from'] ?? ''),
    to: DateTime.tryParse(params['to'] ?? ''),
    paid: switch (params['paid']) {
      'yes' => true,
      'no' => false,
      _ => null,
    },
    page: (int.tryParse(params['page'] ?? '') ?? 0).clamp(0, 1 << 20),
    size: (int.tryParse(params['size'] ?? '') ?? defaultBookingQuery.size)
        .clamp(1, 100),
  );

  static Map<String, String> encode(AdminBookingQuery q) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      if (q.status != null) 'status': q.status!.name,
      if (q.bookableId != null) 'flight': '${q.bookableId}',
      if (q.customerId != null) 'customer': '${q.customerId}',
      if (q.from != null) 'from': day(q.from!),
      if (q.to != null) 'to': day(q.to!),
      if (q.paid != null) 'paid': q.paid! ? 'yes' : 'no',
      if (q.page != 0) 'page': '${q.page}',
      if (q.size != defaultBookingQuery.size) 'size': '${q.size}',
    };
  }
}

/// Cópias da consulta com um campo trocado. Mudar um filtro volta à página 0.
class BookingQueryEdit {
  const BookingQueryEdit._();

  static AdminBookingQuery status(AdminBookingQuery q, BookingStatus? v) => (
    status: v,
    bookableId: q.bookableId,
    customerId: q.customerId,
    from: q.from,
    to: q.to,
    paid: q.paid,
    page: 0,
    size: q.size,
  );

  static AdminBookingQuery customer(AdminBookingQuery q, int? v) => (
    status: q.status,
    bookableId: q.bookableId,
    customerId: v,
    from: q.from,
    to: q.to,
    paid: q.paid,
    page: 0,
    size: q.size,
  );

  static AdminBookingQuery flight(AdminBookingQuery q, int? v) => (
    status: q.status,
    bookableId: v,
    customerId: q.customerId,
    from: q.from,
    to: q.to,
    paid: q.paid,
    page: 0,
    size: q.size,
  );

  static AdminBookingQuery period(
    AdminBookingQuery q,
    DateTime? from,
    DateTime? to,
  ) => (
    status: q.status,
    bookableId: q.bookableId,
    customerId: q.customerId,
    from: from,
    to: to,
    paid: q.paid,
    page: 0,
    size: q.size,
  );

  static AdminBookingQuery paid(AdminBookingQuery q, bool? v) => (
    status: q.status,
    bookableId: q.bookableId,
    customerId: q.customerId,
    from: q.from,
    to: q.to,
    paid: v,
    page: 0,
    size: q.size,
  );

  static AdminBookingQuery page(AdminBookingQuery q, int v) => (
    status: q.status,
    bookableId: q.bookableId,
    customerId: q.customerId,
    from: q.from,
    to: q.to,
    paid: q.paid,
    page: v,
    size: q.size,
  );

  static AdminBookingQuery size(AdminBookingQuery q, int v) => (
    status: q.status,
    bookableId: q.bookableId,
    customerId: q.customerId,
    from: q.from,
    to: q.to,
    paid: q.paid,
    page: 0,
    size: v,
  );

  static AdminBookingQuery cleared(AdminBookingQuery q) => (
    status: null,
    bookableId: null,
    customerId: null,
    from: null,
    to: null,
    paid: null,
    page: 0,
    size: q.size,
  );
}
