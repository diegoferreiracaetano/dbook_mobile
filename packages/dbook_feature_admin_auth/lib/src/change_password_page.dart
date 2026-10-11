import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_scaffold.dart';
import 'password_rules.dart';

/// Troca de senha de quem está logado. Com [forced] (o servidor mandou
/// `mustChangePassword`) é o único caminho até trocar. Ao trocar, o servidor
/// encerra todas as sessões: o roteador leva ao login com o aviso.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key, this.forced = false});

  final bool forced;

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _next.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
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
          .read(adminSessionProvider.notifier)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(staffProfileProvider)?.email ?? '';
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.forced)
            Padding(
              padding: const EdgeInsets.only(bottom: DbookSpacing.md),
              child: DbookInlineStatusBanner(
                message: l10n.passwordMustChange,
                tone: DbookBannerTone.warning,
              ),
            ),
          if (_error != null) FormErrorText(_error!),
          DbookTextField(
            label: l10n.passwordCurrent,
            controller: _current,
            obscureText: true,
            autofocus: true,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.loginRequired : null,
          ),
          const SizedBox(height: DbookSpacing.lg),
          DbookTextField(
            label: l10n.passwordNew,
            controller: _next,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (v) => PasswordRules.acceptable(v ?? '', email)
                ? null
                : l10n.errValidation,
          ),
          const SizedBox(height: DbookSpacing.md),
          PasswordRequirements(password: _next.text, email: email),
          const SizedBox(height: DbookSpacing.lg),
          DbookTextField(
            label: l10n.passwordConfirm,
            controller: _repeat,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (v) => v == _next.text ? null : l10n.passwordMismatch,
          ),
          const SizedBox(height: DbookSpacing.sm),
          Text(
            l10n.accountSessionNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: DbookSpacing.xl),
          DbookButton(
            label: l10n.passwordChangeSubmit,
            isLoading: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );

    if (widget.forced) {
      return AuthScaffold(title: l10n.passwordChangeTitle, child: form);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.passwordChangeTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DbookSpacing.xl),
              form,
            ],
          ),
        ),
      ),
    );
  }
}
