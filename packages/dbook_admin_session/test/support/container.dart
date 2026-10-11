import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fakes.dart';

ProviderContainer sessionContainer(
  FakeAdminAuthApi api, {
  DateTime Function()? clock,
}) {
  final container = ProviderContainer(
    overrides: [
      adminBaseUrlProvider.overrideWithValue('http://api/v1'),
      adminAuthApiProvider.overrideWithValue(api),
      adminAccountApiProvider.overrideWithValue(api),
      if (clock != null) adminClockProvider.overrideWithValue(clock),
    ],
  );
  return container;
}
