import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_scaffold.dart';
import 'password_rules.dart';

/// Aceitar o convite da equipe (`/accept-invite?token=`). O token vem da URL;
/// convite vencido, usado ou revogado recebe **a mesma mensagem** (o servidor
/// responde igual de propósito, para não revelar qual foi o caso).
class AcceptInvitePage extends ConsumerStatefulWidget {
  const AcceptInvitePage({
    super.key,
    required this.token,
    required this.onGoToLogin,
  });

  final String? token;
  final VoidCallback onGoToLogin;

  @override
  ConsumerState<AcceptInvitePage> createState() => _AcceptInvitePageState();
}

class _AcceptInvitePageState extends ConsumerState<AcceptInvitePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;
  bool _invalid = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _invalid = widget.token == null || widget.token!.isEmpty;
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(adminAuthApiProvider)
          .acceptInvitation(
            token: widget.token!,
            name: _name.text.trim(),
            password: _password.text,
          );
      if (mounted) setState(() => _done = true);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      if (error.code == 'INVALID_INVITATION') {
        setState(() => _invalid = true);
      } else {
        setState(() => _error = portalErrorMessage(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_done) {
      return AuthScaffold(
        title: l10n.inviteSuccessTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.inviteAccepted),
            const SizedBox(height: DbookSpacing.xl),
            DbookButton(
              label: l10n.inviteGoToLogin,
              onPressed: widget.onGoToLogin,
            ),
          ],
        ),
      );
    }

    if (_invalid) {
      return AuthScaffold(
        title: l10n.inviteAcceptTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormErrorText(
              widget.token == null || widget.token!.isEmpty
                  ? l10n.inviteMissingToken
                  : l10n.inviteInvalid,
            ),
            const SizedBox(height: DbookSpacing.md),
            DbookButton(
              label: l10n.inviteGoToLogin,
              variant: DbookButtonVariant.secondary,
              onPressed: widget.onGoToLogin,
            ),
          ],
        ),
      );
    }

    return AuthScaffold(
      title: l10n.inviteAcceptTitle,
      subtitle: l10n.inviteAcceptSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) FormErrorText(_error!),
            DbookTextField(
              label: l10n.inviteName,
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.loginRequired : null,
            ),
            const SizedBox(height: DbookSpacing.lg),
            DbookTextField(
              label: l10n.passwordNew,
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  PasswordRules.longEnough(v ?? '') &&
                      PasswordRules.notTooLong(v ?? '')
                  ? null
                  : l10n.passwordReqLength,
            ),
            const SizedBox(height: DbookSpacing.md),
            PasswordRequirements(password: _password.text, email: ''),
            const SizedBox(height: DbookSpacing.lg),
            DbookTextField(
              label: l10n.passwordConfirm,
              controller: _repeat,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) =>
                  v == _password.text ? null : l10n.passwordMismatch,
            ),
            const SizedBox(height: DbookSpacing.xl),
            DbookButton(
              label: l10n.inviteAcceptSubmit,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
