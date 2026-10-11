import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// O ciclo de vida do app na frente de tudo: versão **abaixo da mínima** que o
/// servidor aceita vira uma tela única de "Atualize o app"; versão defasada
/// mas aceita mostra um aviso que se dispensa. Sem resposta do servidor, o
/// app abre normalmente (ver `appUpdateProvider`).
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> {
  bool _dismissed = false;

  Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(appUpdateProvider).value ?? UpdateInfo.none;

    if (info.status == UpdateStatus.required) {
      return _UpdateRequiredScreen(
        onUpdate: () => _openStore(info.storeUrl),
        hasStore: info.storeUrl.isNotEmpty,
      );
    }

    if (info.status == UpdateStatus.available && !_dismissed) {
      return Column(
        children: [
          Expanded(child: widget.child),
          Material(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DbookSpacing.md,
                  vertical: DbookSpacing.xs,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.system_update_alt, size: 18),
                    const SizedBox(width: DbookSpacing.sm),
                    const Expanded(child: Text('Há uma versão nova do app.')),
                    if (info.storeUrl.isNotEmpty)
                      TextButton(
                        onPressed: () => _openStore(info.storeUrl),
                        child: const Text('Atualizar'),
                      ),
                    IconButton(
                      tooltip: 'Dispensar',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _dismissed = true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return widget.child;
  }
}

class _UpdateRequiredScreen extends StatelessWidget {
  const _UpdateRequiredScreen({required this.onUpdate, required this.hasStore});

  final VoidCallback onUpdate;
  final bool hasStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DbookStatusPlaceholder(
          icon: Icons.system_update_alt,
          title: 'Atualize o app para continuar',
          message:
              'Esta versão do DBook não é mais aceita. Instale a versão mais '
              'nova na loja e abra o app de novo.',
          actionLabel: hasStore ? 'Atualizar' : null,
          onAction: hasStore ? onUpdate : null,
        ),
      ),
    );
  }
}
