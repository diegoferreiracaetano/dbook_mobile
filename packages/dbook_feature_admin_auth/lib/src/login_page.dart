import 'dart:async';

import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_scaffold.dart';
import 'two_factor_panels.dart';

/// A porta do portal. Quem decide o que aparece é o estado da sessão: e-mail e
/// senha, segundo fator (código ou cadastro) ou os códigos de recuperação. O
/// roteador leva a pessoa embora quando a sessão começa.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(adminSessionProvider);
    final notifier = ref.read(adminSessionProvider.notifier);

    return switch (state) {
      SessionRestoring() => AuthScaffold(
        title: l10n.appTitle,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: DbookSpacing.md),
            Text(l10n.loginRestoring),
          ],
        ),
      ),
      SessionSignedOut(:final reason) => AuthScaffold(
        title: l10n.loginTitle,
        subtitle: l10n.loginSubtitle,
        child: _LoginForm(reason: reason),
      ),
      SessionChallenge(:final enrollmentRequired) =>
        enrollmentRequired
            ? AuthScaffold(
                title: l10n.twoFactorEnrollTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TwoFactorEnrollmentPanel(
                      load: notifier.startEnrollment,
                      onConfirm: notifier.confirmEnrollment,
                    ),
                    const SizedBox(height: DbookSpacing.md),
                    TextButton(
                      onPressed: notifier.cancelChallenge,
                      child: Text(l10n.twoFactorBack),
                    ),
                  ],
                ),
              )
            : AuthScaffold(
                title: l10n.twoFactorTitle,
                subtitle: l10n.twoFactorSubtitle,
                child: const _TwoFactorCodeForm(),
              ),
      SessionRecoveryCodes(:final codes) => AuthScaffold(
        title: l10n.twoFactorRecoveryTitle,
        child: RecoveryCodesPanel(
          codes: codes,
          onDone: notifier.acknowledgeRecoveryCodes,
        ),
      ),
      SessionSignedIn() => const SizedBox.shrink(),
    };
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm({required this.reason});

  final SessionEndReason reason;

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _busy = false;
  Object? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _cooldown > 0) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(adminSessionProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
      if (error is DbookNetworkException && error.code == 'TOO_MANY_ATTEMPTS') {
        _startCooldown(error.retryAfter ?? 60);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _cooldown -= 1);
      if (_cooldown <= 0) {
        timer.cancel();
        setState(() => _error = null);
      }
    });
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty)
      ? context.l10n.loginRequired
      : null;

  String? _reasonMessage(AppLocalizations l10n) => switch (widget.reason) {
    SessionEndReason.idle => l10n.loginReasonIdle,
    SessionEndReason.expired => l10n.loginReasonExpired,
    SessionEndReason.loggedOut => l10n.loginReasonLoggedOut,
    SessionEndReason.passwordChanged => l10n.passwordChanged,
    SessionEndReason.none => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reason = _reasonMessage(l10n);
    final error = _error;
    final message = _cooldown > 0
        ? l10n.errTooManyAttempts(_cooldown)
        : (error == null ? null : portalErrorMessage(l10n, error));

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (reason != null && message == null)
              Padding(
                padding: const EdgeInsets.only(bottom: DbookSpacing.md),
                child: DbookInlineStatusBanner(message: reason),
              ),
            if (message != null) FormErrorText(message),
            DbookTextField(
              label: l10n.loginEmail,
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              validator: _required,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: DbookSpacing.lg),
            DbookTextField(
              label: l10n.loginPassword,
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: _required,
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                tooltip: _obscure
                    ? l10n.loginShowPassword
                    : l10n.loginHidePassword,
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: DbookSpacing.xl),
            DbookButton(
              label: l10n.loginSubmit,
              isLoading: _busy,
              onPressed: _cooldown > 0 ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoFactorCodeForm extends ConsumerStatefulWidget {
  const _TwoFactorCodeForm();

  @override
  ConsumerState<_TwoFactorCodeForm> createState() => _TwoFactorCodeFormState();
}

class _TwoFactorCodeFormState extends ConsumerState<_TwoFactorCodeForm> {
  final _codeKey = GlobalKey<DbookCodeInputState>();
  final _recovery = TextEditingController();
  bool _useRecovery = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _recovery.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (_busy || code.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(adminSessionProvider.notifier)
          .verifyTwoFactor(code.trim());
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) FormErrorText(_error!),
        if (_useRecovery) ...[
          DbookTextField(
            label: l10n.twoFactorRecoveryLabel,
            controller: _recovery,
            autofocus: true,
            onSubmitted: _verify,
          ),
          const SizedBox(height: DbookSpacing.lg),
          DbookButton(
            label: l10n.twoFactorVerify,
            isLoading: _busy,
            onPressed: () => _verify(_recovery.text),
          ),
        ] else
          Center(
            child: DbookCodeInput(
              key: _codeKey,
              enabled: !_busy,
              onCompleted: _verify,
              semanticLabel: l10n.twoFactorTitle,
            ),
          ),
        const SizedBox(height: DbookSpacing.md),
        TextButton(
          onPressed: () => setState(() {
            _useRecovery = !_useRecovery;
            _error = null;
          }),
          child: Text(
            _useRecovery ? l10n.twoFactorUseApp : l10n.twoFactorUseRecovery,
          ),
        ),
        TextButton(
          onPressed: ref.read(adminSessionProvider.notifier).cancelChallenge,
          child: Text(l10n.twoFactorBack),
        ),
      ],
    );
  }
}
