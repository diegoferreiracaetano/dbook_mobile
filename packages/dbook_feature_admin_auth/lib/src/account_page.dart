import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_scaffold.dart';
import 'two_factor_panels.dart';

/// "Minha conta": quem sou eu, meu papel, segundo fator e troca de senha.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key, required this.onChangePassword});

  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(staffProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.accountTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: DbookSpacing.lg),
              DbookDefinitionList(
                items: [
                  DbookDefinition(label: profile.name, value: profile.email),
                  DbookDefinition(
                    label: l10n.accountRole,
                    value: roleLabel(l10n, profile.role),
                  ),
                  DbookDefinition(
                    label: l10n.accountPermissions,
                    value: profile.permissions.isEmpty
                        ? l10n.accountNoPermissions
                        : l10n.accountPermissionCount(
                            profile.permissions.length,
                          ),
                  ),
                  DbookDefinition(
                    label: l10n.accountTwoFactor,
                    child: DbookStatusBadge(
                      status: profile.twoFactorEnabled
                          ? DbookStatus.confirmed
                          : DbookStatus.pending,
                      label: profile.twoFactorEnabled
                          ? l10n.twoFactorEnabled
                          : l10n.twoFactorDisabled,
                      showIcon: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DbookSpacing.lg),
              Wrap(
                spacing: DbookSpacing.sm,
                runSpacing: DbookSpacing.sm,
                children: [
                  DbookButton(
                    label: l10n.accountChangePassword,
                    variant: DbookButtonVariant.secondary,
                    onPressed: onChangePassword,
                  ),
                  if (!profile.twoFactorEnabled)
                    DbookButton(
                      label: l10n.accountEnableTwoFactor,
                      onPressed: () => _enable(context, ref),
                    )
                  else if (!profile.twoFactorRequired)
                    DbookButton(
                      label: l10n.accountDisableTwoFactor,
                      variant: DbookButtonVariant.secondary,
                      onPressed: () => _disable(context, ref),
                    ),
                ],
              ),
              if (profile.twoFactorEnabled && profile.twoFactorRequired) ...[
                const SizedBox(height: DbookSpacing.sm),
                Text(
                  l10n.twoFactorRequiredByRole,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final api = ref.read(adminAccountApiProvider);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _EnableTwoFactorDialog(api: api),
    );
    await ref.read(adminSessionProvider.notifier).reloadProfile();
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final api = ref.read(adminAccountApiProvider);
    final done = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DisableTwoFactorDialog(api: api),
    );
    if (done ?? false) {
      await ref.read(adminSessionProvider.notifier).reloadProfile();
    }
  }
}

class _EnableTwoFactorDialog extends StatefulWidget {
  const _EnableTwoFactorDialog({required this.api});

  final AdminAuthApi api;

  @override
  State<_EnableTwoFactorDialog> createState() => _EnableTwoFactorDialogState();
}

class _EnableTwoFactorDialogState extends State<_EnableTwoFactorDialog> {
  List<String>? _codes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final codes = _codes;

    return AlertDialog(
      title: Text(
        codes == null ? l10n.twoFactorEnrollTitle : l10n.twoFactorRecoveryTitle,
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: codes == null
              ? TwoFactorEnrollmentPanel(
                  load: widget.api.enrollTwoFactor,
                  onConfirm: (code) async {
                    final recovery = await widget.api.confirmTwoFactor(code);
                    if (mounted) setState(() => _codes = recovery);
                  },
                )
              : RecoveryCodesPanel(
                  codes: codes,
                  onDone: () => Navigator.of(context).pop(),
                ),
        ),
      ),
      actions: [
        if (codes == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
      ],
    );
  }
}

class _DisableTwoFactorDialog extends StatefulWidget {
  const _DisableTwoFactorDialog({required this.api});

  final AdminAuthApi api;

  @override
  State<_DisableTwoFactorDialog> createState() =>
      _DisableTwoFactorDialogState();
}

class _DisableTwoFactorDialogState extends State<_DisableTwoFactorDialog> {
  final _password = TextEditingController();
  String _code = '';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _password.text.isEmpty || _code.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.disableTwoFactor(password: _password.text, code: _code);
      if (mounted) Navigator.of(context).pop(true);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _error = error is DbookConflictException
            ? l10n.twoFactorRequiredByRole
            : portalErrorMessage(l10n, error);
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.twoFactorDisableTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) FormErrorText(_error!),
            DbookTextField(
              label: l10n.twoFactorDisablePassword,
              controller: _password,
              obscureText: true,
              autofocus: true,
            ),
            const SizedBox(height: DbookSpacing.lg),
            Text(l10n.twoFactorDisableCode),
            const SizedBox(height: DbookSpacing.xs),
            DbookCodeInput(
              autofocus: false,
              onChanged: (value) => _code = value,
              onCompleted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        DbookButton(
          label: l10n.twoFactorDisableSubmit,
          isLoading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
