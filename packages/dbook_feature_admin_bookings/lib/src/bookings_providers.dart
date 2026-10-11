import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminBookingsApiProvider = Provider<AdminBookingsApi>(
  (ref) => DioAdminBookingsApi(ref.watch(adminDioProvider)),
);

final adminBookingsProvider = FutureProvider.autoDispose
    .family<PageOf<AdminBooking>, AdminBookingQuery>(
      (ref, query) => ref.watch(adminBookingsApiProvider).list(query),
    );

final adminBookingDetailProvider = FutureProvider.autoDispose
    .family<AdminBookingDetail, int>(
      (ref, id) => ref.watch(adminBookingsApiProvider).get(id),
    );

final refundsProvider = FutureProvider.autoDispose
    .family<PageOf<Refund>, RefundQuery>(
      (ref, query) => ref.watch(adminBookingsApiProvider).listRefunds(query),
    );
