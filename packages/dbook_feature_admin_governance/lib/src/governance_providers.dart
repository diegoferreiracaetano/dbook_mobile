import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auditApiProvider = Provider<AuditApi>(
  (ref) => DioAuditApi(ref.watch(adminDioProvider)),
);

final governanceApiProvider = Provider<GovernanceApi>(
  (ref) => DioGovernanceApi(ref.watch(adminDioProvider)),
);

typedef ReviewsRequest = ({ReviewQueue queue, int page});

final reviewsProvider = FutureProvider.autoDispose
    .family<PageOf<AdminReview>, ReviewsRequest>(
      (ref, request) => ref
          .watch(governanceApiProvider)
          .reviews(queue: request.queue, page: request.page),
    );

final promosProvider = FutureProvider.autoDispose
    .family<PageOf<Promo>, PromoQuery>(
      (ref, query) => ref.watch(governanceApiProvider).promos(query),
    );

final promoRedemptionsProvider = FutureProvider.autoDispose
    .family<List<PromoRedemption>, int>(
      (ref, id) => ref.watch(governanceApiProvider).redemptions(id),
    );
