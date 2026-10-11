import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/app_config.dart';
import 'src/connectivity.dart';
import 'src/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandling();
  // Endereços sem `#`: o link direto e a recarga preservam a tela. O servidor
  // estático precisa devolver o `index.html` nas rotas (ver docs/portal.md).
  usePathUrlStrategy();
  await PortalFormats.init();

  final config = AppConfig.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        adminBaseUrlProvider.overrideWithValue(config.apiBaseUrl),
        adminNetworkLoggingProvider.overrideWithValue(kDebugMode),
        adminAppClientProvider.overrideWithValue(
          AppClientInfo(version: config.version, platform: 'web'),
        ),
      ],
      child: const DbookAdminApp(),
    ),
  );
}
