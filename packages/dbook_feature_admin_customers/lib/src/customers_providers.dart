import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customersApiProvider = Provider<CustomersApi>(
  (ref) => DioCustomersApi(ref.watch(adminDioProvider)),
);

final auditApiProvider = Provider<AuditApi>(
  (ref) => DioAuditApi(ref.watch(adminDioProvider)),
);

/// A lista, por consulta: a consulta inteira é a chave, então mudar um filtro,
/// a ordem ou a página é só pedir outra chave. O cache se descarta sozinho
/// quando ninguém olha.
final customersProvider = FutureProvider.autoDispose
    .family<PageOf<CustomerSummary>, CustomerQuery>(
      (ref, query) => ref.watch(customersApiProvider).list(query),
    );

final customerDetailProvider = FutureProvider.autoDispose
    .family<CustomerDetail, int>(
      (ref, id) => ref.watch(customersApiProvider).get(id),
    );

// Cada aba só busca quando é aberta: o provider só é lido por ela.
final customerBookingsProvider = FutureProvider.autoDispose
    .family<List<CustomerBooking>, int>(
      (ref, id) => ref.watch(customersApiProvider).bookings(id),
    );

final customerPaymentsProvider = FutureProvider.autoDispose
    .family<List<CustomerPayment>, int>(
      (ref, id) => ref.watch(customersApiProvider).payments(id),
    );

final customerReviewsProvider = FutureProvider.autoDispose
    .family<List<CustomerReview>, int>(
      (ref, id) => ref.watch(customersApiProvider).reviews(id),
    );

final customerNotesProvider = FutureProvider.autoDispose
    .family<List<CustomerNote>, int>(
      (ref, id) => ref.watch(customersApiProvider).notes(id),
    );

final customerHistoryProvider = FutureProvider.autoDispose
    .family<CursorPage<AuditEntry>, int>(
      (ref, id) => ref.watch(auditApiProvider).search((
        actorId: null,
        action: null,
        targetType: 'CUSTOMER',
        targetId: '$id',
        outcome: null,
        from: null,
        to: null,
        cursor: null,
        size: 50,
      )),
    );
