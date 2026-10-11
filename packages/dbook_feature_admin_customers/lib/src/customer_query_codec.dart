import 'package:dbook_admin_data/dbook_admin_data.dart';

/// A consulta da lista ↔ a *query string* da URL: link direto e recarga
/// preservam busca, filtros, ordem e página. Só o que difere do padrão vai
/// para a URL.
class CustomerQueryCodec {
  const CustomerQueryCodec._();

  static CustomerQuery decode(Map<String, String> params) {
    final base = defaultCustomerQuery;
    return (
      text: params['q'] ?? '',
      status: switch (params['status']) {
        'active' => CustomerStatus.active,
        'blocked' => CustomerStatus.blocked,
        _ => null,
      },
      from: DateTime.tryParse(params['from'] ?? ''),
      to: DateTime.tryParse(params['to'] ?? ''),
      hasBookings: switch (params['bookings']) {
        'yes' => true,
        'no' => false,
        _ => null,
      },
      sort: CustomerSort.values.asNameMap()[params['sort']] ?? base.sort,
      descending: params['dir'] == null
          ? base.descending
          : params['dir'] == 'desc',
      page: (int.tryParse(params['page'] ?? '') ?? 0).clamp(0, 1 << 20),
      size: (int.tryParse(params['size'] ?? '') ?? base.size).clamp(1, 100),
    );
  }

  static Map<String, String> encode(CustomerQuery q) {
    final base = defaultCustomerQuery;
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      if (q.text.isNotEmpty) 'q': q.text,
      if (q.status != null) 'status': q.status!.name,
      if (q.from != null) 'from': day(q.from!),
      if (q.to != null) 'to': day(q.to!),
      if (q.hasBookings != null) 'bookings': q.hasBookings! ? 'yes' : 'no',
      if (q.sort != base.sort) 'sort': q.sort.name,
      if (q.descending != base.descending) 'dir': q.descending ? 'desc' : 'asc',
      if (q.page != 0) 'page': '${q.page}',
      if (q.size != base.size) 'size': '${q.size}',
    };
  }
}

/// Cópias da consulta com um campo trocado (records não têm `copyWith`).
/// Mudar qualquer filtro volta para a primeira página.
class CustomerQueryEdit {
  const CustomerQueryEdit._();

  static CustomerQuery text(CustomerQuery q, String value) => (
    text: value,
    status: q.status,
    from: q.from,
    to: q.to,
    hasBookings: q.hasBookings,
    sort: q.sort,
    descending: q.descending,
    page: 0,
    size: q.size,
  );

  static CustomerQuery status(CustomerQuery q, CustomerStatus? value) => (
    text: q.text,
    status: value,
    from: q.from,
    to: q.to,
    hasBookings: q.hasBookings,
    sort: q.sort,
    descending: q.descending,
    page: 0,
    size: q.size,
  );

  static CustomerQuery period(CustomerQuery q, DateTime? from, DateTime? to) =>
      (
        text: q.text,
        status: q.status,
        from: from,
        to: to,
        hasBookings: q.hasBookings,
        sort: q.sort,
        descending: q.descending,
        page: 0,
        size: q.size,
      );

  static CustomerQuery hasBookings(CustomerQuery q, bool? value) => (
    text: q.text,
    status: q.status,
    from: q.from,
    to: q.to,
    hasBookings: value,
    sort: q.sort,
    descending: q.descending,
    page: 0,
    size: q.size,
  );

  static CustomerQuery sort(
    CustomerQuery q,
    CustomerSort sort,
    bool descending,
  ) => (
    text: q.text,
    status: q.status,
    from: q.from,
    to: q.to,
    hasBookings: q.hasBookings,
    sort: sort,
    descending: descending,
    page: 0,
    size: q.size,
  );

  static CustomerQuery page(CustomerQuery q, int page) => (
    text: q.text,
    status: q.status,
    from: q.from,
    to: q.to,
    hasBookings: q.hasBookings,
    sort: q.sort,
    descending: q.descending,
    page: page,
    size: q.size,
  );

  static CustomerQuery size(CustomerQuery q, int size) => (
    text: q.text,
    status: q.status,
    from: q.from,
    to: q.to,
    hasBookings: q.hasBookings,
    sort: q.sort,
    descending: q.descending,
    page: 0,
    size: size,
  );
}
