import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Onde os erros não tratados são registrados. Hoje: o console do navegador e
/// os últimos 50 em memória (para a tela de suporte, se vier). Trocar por um
/// serviço de monitoramento é mudar só esta função. **Nunca** logar token,
/// dado de cliente ou corpo de requisição.
void Function(Object error, StackTrace? stack) portalErrorSink =
    (error, stack) {
      debugPrint('[portal] erro não tratado: ${error.runtimeType}');
      if (kDebugMode) debugPrintStack(stackTrace: stack);
    };

final List<String> recentPortalErrors = [];

void _record(Object error, StackTrace? stack) {
  recentPortalErrors.add(
    '${DateTime.now().toIso8601String()} ${error.runtimeType}',
  );
  if (recentPortalErrors.length > 50) recentPortalErrors.removeAt(0);
  portalErrorSink(error, stack);
}

/// Erro de renderização vira tela amigável e registro; erro assíncrono solto
/// também é registrado, em vez de sumir.
void installErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _record(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _record(error, stack);
    return true;
  };
  ErrorWidget.builder = (details) => const CrashView();
}

/// Tela no lugar de um widget que quebrou ao desenhar.
class CrashView extends StatelessWidget {
  const CrashView({super.key});

  @override
  Widget build(BuildContext context) {
    // O texto vem do arb quando há localização; senão, o português direto: a
    // própria localização pode ser o que quebrou.
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return Material(
      child: DbookStatusPlaceholder(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: l10n?.crashTitle ?? 'Algo quebrou nesta tela',
        message:
            l10n?.crashMessage ??
            'O erro foi registrado. Recarregue a página para continuar.',
        actionLabel: l10n?.crashReload ?? 'Recarregar',
        onAction: reloadPage,
      ),
    );
  }
}
