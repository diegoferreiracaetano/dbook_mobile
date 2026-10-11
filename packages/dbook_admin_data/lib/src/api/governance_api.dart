import 'package:dio/dio.dart';

import '../json.dart';
import '../models/governance.dart';
import '../models/pages.dart';

/// Moderação de avaliações e códigos promocionais da equipe
/// (`/v1/admin/reviews`, `/v1/admin/promo-codes`).
abstract interface class GovernanceApi {
  Future<PageOf<AdminReview>> reviews({
    required ReviewQueue queue,
    int page = 0,
    int size = 20,
  });

  Future<void> hideReview(int id, String reason);

  Future<void> restoreReview(int id);

  Future<void> dismissReports(int id);

  Future<PageOf<Promo>> promos(PromoQuery query);

  Future<Promo> createPromo(PromoForm form);

  Future<Promo> updatePromo(int id, PromoForm form);

  Future<Promo> setPromoActive(int id, {required bool active});

  Future<List<PromoRedemption>> redemptions(int id);
}

class DioGovernanceApi implements GovernanceApi {
  const DioGovernanceApi(this._dio);

  final Dio _dio;

  @override
  Future<PageOf<AdminReview>> reviews({
    required ReviewQueue queue,
    int page = 0,
    int size = 20,
  }) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/reviews',
      queryParameters: {
        'status': reviewQueueToWire(queue),
        'page': page,
        'size': size,
      },
    );
    return PageOf.fromJson(bodyOf(response), AdminReview.fromJson);
  });

  @override
  Future<void> hideReview(int id, String reason) => guarded(
    () async =>
        _dio.post<Object>('/admin/reviews/$id/hide', data: {'reason': reason}),
  );

  @override
  Future<void> restoreReview(int id) =>
      guarded(() async => _dio.post<Object>('/admin/reviews/$id/restore'));

  @override
  Future<void> dismissReports(int id) => guarded(
    () async => _dio.post<Object>('/admin/reviews/$id/dismiss-reports'),
  );

  @override
  Future<PageOf<Promo>> promos(PromoQuery q) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/promo-codes',
      queryParameters: compact({
        'active': q.active,
        'page': q.page,
        'size': q.size,
      }),
    );
    return PageOf.fromJson(bodyOf(response), Promo.fromJson);
  });

  @override
  Future<Promo> createPromo(PromoForm form) => guarded(() async {
    final response = await _dio.post<Object>(
      '/admin/promo-codes',
      data: form.createJson(),
    );
    return Promo.fromJson(bodyOf(response));
  });

  @override
  Future<Promo> updatePromo(int id, PromoForm form) => guarded(() async {
    final response = await _dio.put<Object>(
      '/admin/promo-codes/$id',
      data: form.updateJson(),
    );
    return Promo.fromJson(bodyOf(response));
  });

  @override
  Future<Promo> setPromoActive(int id, {required bool active}) =>
      guarded(() async {
        final response = await _dio.post<Object>(
          '/admin/promo-codes/$id/${active ? 'activate' : 'deactivate'}',
        );
        return Promo.fromJson(bodyOf(response));
      });

  @override
  Future<List<PromoRedemption>> redemptions(int id) => guarded(() async {
    final response = await _dio.get<Object>(
      '/admin/promo-codes/$id/redemptions',
    );
    final data = response.data;
    if (data is List) {
      return [
        for (final item in data)
          if (item is Map<String, dynamic>) PromoRedemption.fromJson(item),
      ];
    }
    return bodyOf(response).list('items', PromoRedemption.fromJson);
  });
}
