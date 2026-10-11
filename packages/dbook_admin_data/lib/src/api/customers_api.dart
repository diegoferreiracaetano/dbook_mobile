import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../json.dart';
import '../models/customers.dart';
import '../models/downloaded_file.dart';
import '../models/pages.dart';

/// O CRM de clientes (`/v1/admin/customers`). Só enxerga **clientes**: o id
/// de um membro da equipe é `404`.
abstract interface class CustomersApi {
  Future<PageOf<CustomerSummary>> list(CustomerQuery query);

  Future<CustomerDetail> get(int id);

  Future<List<CustomerBooking>> bookings(int id);

  Future<List<CustomerPayment>> payments(int id);

  Future<List<CustomerReview>> reviews(int id);

  Future<List<CustomerNote>> notes(int id);

  Future<CustomerNote> addNote(
    int id, {
    required String body,
    bool pinned = false,
  });

  Future<CustomerNote> updateNote(
    int id,
    int noteId, {
    String? body,
    bool? pinned,
  });

  Future<void> deleteNote(int id, int noteId);

  Future<CustomerModeration> block(int id, String reason);

  Future<CustomerModeration> unblock(int id);

  Future<DownloadedFile> export(CustomerQuery query);

  Future<CustomerModeration> anonymize(
    int id, {
    required String reason,
    required String confirmation,
  });
}

class DioCustomersApi implements CustomersApi {
  const DioCustomersApi(this._dio);

  final Dio _dio;

  static Map<String, dynamic> _filters(CustomerQuery q) => compact({
    'query': q.text.trim(),
    'status': switch (q.status) {
      CustomerStatus.active => 'ACTIVE',
      CustomerStatus.blocked => 'BLOCKED',
      _ => null,
    },
    'createdFrom': q.from == null
        ? null
        : DateTime(
            q.from!.year,
            q.from!.month,
            q.from!.day,
          ).toUtc().toIso8601String(),
    // o dia final vale inteiro
    'createdTo': q.to == null
        ? null
        : DateTime(
            q.to!.year,
            q.to!.month,
            q.to!.day,
            23,
            59,
            59,
            999,
          ).toUtc().toIso8601String(),
    'hasBookings': q.hasBookings,
    'sort': customerSortWire(q.sort),
    'direction': q.descending ? 'DESC' : 'ASC',
  });

  @override
  Future<PageOf<CustomerSummary>> list(CustomerQuery query) =>
      guarded(() async {
        final response = await _dio.get<Object>(
          '/admin/customers',
          queryParameters: {
            ..._filters(query),
            'page': query.page,
            'size': query.size,
          },
        );
        return PageOf.fromJson(bodyOf(response), CustomerSummary.fromJson);
      });

  @override
  Future<CustomerDetail> get(int id) => guarded(() async {
    final response = await _dio.get<Object>('/admin/customers/$id');
    return CustomerDetail.fromJson(bodyOf(response));
  });

  @override
  Future<List<CustomerBooking>> bookings(int id) =>
      _items('/admin/customers/$id/bookings', CustomerBooking.fromJson);

  @override
  Future<List<CustomerPayment>> payments(int id) =>
      _items('/admin/customers/$id/payments', CustomerPayment.fromJson);

  @override
  Future<List<CustomerReview>> reviews(int id) =>
      _items('/admin/customers/$id/reviews', CustomerReview.fromJson);

  @override
  Future<List<CustomerNote>> notes(int id) =>
      _items('/admin/customers/$id/notes', CustomerNote.fromJson);

  /// A resposta é uma lista, ou uma página (`{items: [...]}`): aceita as duas.
  Future<List<T>> _items<T>(String path, T Function(Json) parse) =>
      guarded(() async {
        final response = await _dio.get<Object>(
          path,
          queryParameters: {'page': 0, 'size': 100},
        );
        final data = response.data;
        if (data is List) {
          return [
            for (final item in data)
              if (item is Map<String, dynamic>) parse(item),
          ];
        }
        return bodyOf(response).list('items', parse);
      });

  @override
  Future<CustomerNote> addNote(
    int id, {
    required String body,
    bool pinned = false,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/customers/$id/notes',
      data: {'body': body, 'pinned': pinned},
    );
    return CustomerNote.fromJson(bodyOf(response));
  });

  @override
  Future<CustomerNote> updateNote(
    int id,
    int noteId, {
    String? body,
    bool? pinned,
  }) => guarded(() async {
    final response = await _dio.patch<Object>(
      '/admin/customers/$id/notes/$noteId',
      data: compact({'body': body, 'pinned': pinned}),
    );
    return CustomerNote.fromJson(bodyOf(response));
  });

  @override
  Future<void> deleteNote(int id, int noteId) => guarded(
    () async => _dio.delete<Object>('/admin/customers/$id/notes/$noteId'),
  );

  @override
  Future<CustomerModeration> block(int id, String reason) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/customers/$id/block',
      data: {'reason': reason},
    );
    return CustomerModeration.fromJson(bodyOf(response));
  });

  @override
  Future<CustomerModeration> unblock(int id) => guarded(() async {
    final response = await _dio.post<Object>('/admin/customers/$id/unblock');
    return CustomerModeration.fromJson(bodyOf(response));
  });

  @override
  Future<DownloadedFile> export(CustomerQuery query) => guarded(() async {
    final response = await _dio.get<List<int>>(
      '/admin/customers/export',
      queryParameters: _filters(query),
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    final disposition = response.headers.value('content-disposition') ?? '';
    final name = RegExp('filename="?([^";]+)"?')
        .firstMatch(disposition)
        ?.group(1);
    return DownloadedFile(
      name: name ?? 'customers.csv',
      bytes: Uint8List.fromList(response.data ?? const []),
    );
  });

  @override
  Future<CustomerModeration> anonymize(
    int id, {
    required String reason,
    required String confirmation,
  }) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/customers/$id/anonymize',
      data: {'reason': reason, 'confirmation': confirmation},
    );
    return CustomerModeration.fromJson(bodyOf(response));
  });
}
