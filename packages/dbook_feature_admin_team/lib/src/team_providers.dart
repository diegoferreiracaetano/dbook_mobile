import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teamApiProvider = Provider<TeamApi>(
  (ref) => DioTeamApi(ref.watch(adminDioProvider)),
);

final staffProvider = FutureProvider.autoDispose<List<StaffMember>>(
  (ref) => ref.watch(teamApiProvider).listStaff(),
);

final invitationsProvider = FutureProvider.autoDispose<List<Invitation>>(
  (ref) => ref.watch(teamApiProvider).listInvitations(),
);
