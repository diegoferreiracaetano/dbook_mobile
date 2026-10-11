import 'dart:convert';

import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_providers.dart';
import '../state/privacy_providers.dart';

/// "Exportar meus dados": busca tudo o que o sistema guarda sobre a pessoa e
/// oferece copiar (JSON). Uma exportação é uma consulta; nada é apagado.
Future<void> showExportMyDataDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _ExportDialog());

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog();

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  late Future<Map<String, dynamic>> _data = ref
      .read(privacyRepositoryProvider)
      .exportMyData();
  bool _copied = false;

  String _summary(Map<String, dynamic> data) {
    int count(String key) => data[key] is List ? (data[key] as List).length : 0;
    return '${count('bookings')} reservas, ${count('payments')} pagamentos e '
        '${count('reviews')} avaliações, além do seu perfil.';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar meus dados'),
      content: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return Text(
              error is DbookNetworkException
                  ? error.message
                  : 'Não foi possível exportar agora. Tente de novo.',
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return const SizedBox(
              height: DbookSizes.loadingXs,
              child: DbookLoadingIndicator(),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estes são os dados que guardamos sobre você:'),
              const SizedBox(height: DbookSpacing.xs),
              Text(
                _summary(data),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: DbookSpacing.md),
              DbookButton(
                label: _copied ? 'Copiado' : 'Copiar tudo (JSON)',
                icon: _copied ? Icons.check : Icons.copy,
                variant: DbookButtonVariant.secondary,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: const JsonEncoder.withIndent('  ').convert(data),
                    ),
                  );
                  if (mounted) setState(() => _copied = true);
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (_data case final future)
          FutureBuilder<Map<String, dynamic>>(
            future: future,
            builder: (context, snapshot) => snapshot.hasError
                ? TextButton(
                    onPressed: () => setState(
                      () => _data = ref
                          .read(privacyRepositoryProvider)
                          .exportMyData(),
                    ),
                    child: const Text('Tentar de novo'),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

/// "Excluir minha conta": explica a consequência em linguagem simples e pede
/// a **senha de novo**. A conta é anonimizada e todas as sessões terminam;
/// não se desfaz. [onDeleted] sai da conta no app.
Future<void> showDeleteAccountDialog(
  BuildContext context, {
  required VoidCallback onDeleted,
}) => showDialog<void>(
  context: context,
  builder: (_) => _DeleteDialog(onDeleted: onDeleted),
);

class _DeleteDialog extends ConsumerStatefulWidget {
  const _DeleteDialog({required this.onDeleted});

  final VoidCallback onDeleted;

  @override
  ConsumerState<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends ConsumerState<_DeleteDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(privacyRepositoryProvider)
          .deleteMyAccount(password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDeleted();
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error) {
          DbookUnauthorizedException() =>
            'Senha incorreta. Confira e tente de novo.',
          DbookConflictException() =>
            'Contas da equipe não podem ser excluídas pelo app.',
          DbookRateLimitException() =>
            'Muitas tentativas. Aguarde um pouco e tente de novo.',
          _ => 'Não foi possível excluir agora. Tente de novo.',
        };
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Excluir minha conta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu nome, e-mail e dados pessoais serão apagados de forma definitiva '
            'e você sairá de todos os aparelhos. As reservas e os pagamentos '
            'continuam registrados, sem identificar você. Não dá para desfazer.',
          ),
          const SizedBox(height: DbookSpacing.md),
          TextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            onSubmitted: (_) =>
                _password.text.isEmpty || _busy ? null : _submit(),
            decoration: InputDecoration(
              labelText: 'Digite sua senha para confirmar',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _busy || _password.text.isEmpty ? null : _submit,
          child: const Text('Excluir minha conta'),
        ),
      ],
    );
  }
}

/// Só para o `authNotifierProvider` ficar acessível a quem chama `onDeleted`.
void signOutLocally(WidgetRef ref) =>
    ref.read(authNotifierProvider.notifier).logout();
