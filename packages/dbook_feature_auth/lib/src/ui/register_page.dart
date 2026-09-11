import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_providers.dart';
import '../state/auth_state.dart';
import 'auth_validators.dart';

/// Tela de cadastro — e-mail/senha/confirmação + aceite dos termos, chama
/// `AuthNotifier.register` (que já loga automaticamente em seguida, já que
/// `/auth/register` não devolve tokens). [onRegistered] dispara quando o
/// estado vira `loggedIn`.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.onRegistered, this.onNavigateToLogin});

  final VoidCallback? onRegistered;
  final VoidCallback? onNavigateToLogin;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _obscurePassword = true;
  var _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_agreedToTerms) return;

    ref
        .read(authNotifierProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthLoggedIn) widget.onRegistered?.call();
    });

    final state = ref.watch(authNotifierProvider);
    final isLoading = state is AuthLoading;

    return Scaffold(
      appBar: const DbookAppBar(title: 'Join Dbook'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: AuthValidators.email,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: AuthValidators.password,
              ),
              const SizedBox(height: DbookSpacing.md),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(labelText: 'Confirmar senha'),
                validator: AuthValidators.confirmPassword(_passwordController),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: DbookSpacing.sm),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreedToTerms,
                onChanged: (value) =>
                    setState(() => _agreedToTerms = value ?? false),
                title: const Text('Aceito os Termos de Serviço'),
              ),
              if (state is AuthError) ...[
                const SizedBox(height: DbookSpacing.sm),
                DbookInlineStatusBanner(
                  message: state.message,
                  tone: DbookBannerTone.warning,
                ),
              ],
              const SizedBox(height: DbookSpacing.lg),
              DbookButton(
                label: 'Create Account',
                isLoading: isLoading,
                onPressed: (isLoading || !_agreedToTerms) ? null : _submit,
              ),
              const SizedBox(height: DbookSpacing.lg),
              TextButton(
                onPressed: widget.onNavigateToLogin,
                child: const Text('Já tem conta? Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
