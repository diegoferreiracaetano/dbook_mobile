import 'dart:convert';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'auth_scaffold.dart';

/// Cadastro do autenticador: QR a partir da URI `otpauth://`, a chave para
/// digitar à mão e o campo do código de confirmação. Serve ao cadastro
/// durante o login e ao cadastro feito depois, na conta.
class TwoFactorEnrollmentPanel extends StatefulWidget {
  const TwoFactorEnrollmentPanel({
    super.key,
    required this.load,
    required this.onConfirm,
  });

  final Future<TwoFactorEnrollment> Function() load;
  final Future<void> Function(String code) onConfirm;

  @override
  State<TwoFactorEnrollmentPanel> createState() =>
      _TwoFactorEnrollmentPanelState();
}

class _TwoFactorEnrollmentPanelState extends State<TwoFactorEnrollmentPanel> {
  final _codeKey = GlobalKey<DbookCodeInputState>();
  late final Future<TwoFactorEnrollment> _enrollment = widget.load();
  String? _error;
  bool _busy = false;

  Future<void> _confirm(String code) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm(code);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
      _codeKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return FutureBuilder<TwoFactorEnrollment>(
      future: _enrollment,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FormErrorText(portalErrorMessage(l10n, snapshot.error!));
        }
        final enrollment = snapshot.data;
        if (enrollment == null) {
          return Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: DbookSpacing.md),
              Text(l10n.twoFactorEnrollLoading),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.twoFactorEnrollSteps, style: theme.textTheme.bodyMedium),
            const SizedBox(height: DbookSpacing.lg),
            Center(
              child: Semantics(
                label: l10n.twoFactorManualKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(DbookSpacing.sm),
                  child: QrImageView(
                    data: enrollment.otpauthUri,
                    size: 176,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: DbookSpacing.md),
            Text(l10n.twoFactorManualKey, style: theme.textTheme.bodySmall),
            SelectableText(
              enrollment.manualEntryKey,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: DbookSpacing.lg),
            if (_error != null) FormErrorText(_error!),
            DbookCodeInput(
              key: _codeKey,
              enabled: !_busy,
              autofocus: false,
              onCompleted: _confirm,
              semanticLabel: l10n.twoFactorTitle,
            ),
          ],
        );
      },
    );
  }
}

/// Os códigos de recuperação, mostrados **uma única vez**: copiar, baixar e só
/// continuar depois de confirmar que foram guardados.
class RecoveryCodesPanel extends StatefulWidget {
  const RecoveryCodesPanel({
    super.key,
    required this.codes,
    required this.onDone,
  });

  final List<String> codes;
  final VoidCallback onDone;

  @override
  State<RecoveryCodesPanel> createState() => _RecoveryCodesPanelState();
}

class _RecoveryCodesPanelState extends State<RecoveryCodesPanel> {
  bool _saved = false;
  bool _copied = false;

  String get _text => widget.codes.join('\n');

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (mounted) setState(() => _copied = true);
  }

  void _download() {
    downloadFile(
      name: context.l10n.twoFactorRecoveryFile,
      bytes: Uint8List.fromList(utf8.encode('$_text\n')),
      mimeType: 'text/plain;charset=utf-8',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.twoFactorRecoveryMessage, style: theme.textTheme.bodyMedium),
        const SizedBox(height: DbookSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DbookSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(DbookRadius.sm),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Wrap(
            spacing: DbookSpacing.xl,
            runSpacing: DbookSpacing.xs,
            children: [
              for (final code in widget.codes)
                SelectableText(
                  code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DbookSpacing.md),
        Wrap(
          spacing: DbookSpacing.sm,
          children: [
            DbookButton(
              label: _copied ? l10n.commonCopied : l10n.commonCopy,
              icon: _copied ? Icons.check : Icons.copy,
              variant: DbookButtonVariant.secondary,
              onPressed: _copy,
            ),
            DbookButton(
              label: l10n.commonDownload,
              icon: Icons.download,
              variant: DbookButtonVariant.secondary,
              onPressed: _download,
            ),
          ],
        ),
        const SizedBox(height: DbookSpacing.md),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _saved,
          title: Text(l10n.twoFactorRecoveryAck),
          onChanged: (value) => setState(() => _saved = value ?? false),
        ),
        const SizedBox(height: DbookSpacing.sm),
        DbookButton(
          label: l10n.twoFactorRecoveryDone,
          onPressed: _saved ? widget.onDone : null,
        ),
      ],
    );
  }
}
