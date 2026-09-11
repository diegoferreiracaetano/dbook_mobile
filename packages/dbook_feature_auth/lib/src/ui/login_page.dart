import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_providers.dart';
import '../state/auth_state.dart';
import 'auth_validators.dart';

/// Tela de login — e-mail/senha, chama `AuthNotifier.login`.
/// [onLoggedIn] dispara quando o estado vira `loggedIn` (navegação é
/// decisão do app, não da feature). [onNavigateToRegister] abre a tela de
/// cadastro.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.onLoggedIn, this.onNavigateToRegister});

  final VoidCallback? onLoggedIn;
  final VoidCallback? onNavigateToRegister;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthLoggedIn) widget.onLoggedIn?.call();
    });

    final state = ref.watch(authNotifierProvider);
    final isLoading = state is AuthLoading;

    return Scaffold(
      appBar: const DbookAppBar(title: 'Welcome Back'),
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
                autofillHints: const [AutofillHints.password],
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
                onFieldSubmitted: (_) => _submit(),
              ),
              if (state is AuthError) ...[
                const SizedBox(height: DbookSpacing.md),
                DbookInlineStatusBanner(
                  message: state.message,
                  tone: DbookBannerTone.warning,
                ),
              ],
              const SizedBox(height: DbookSpacing.xl),
              DbookButton(
                label: 'Sign In',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: DbookSpacing.lg),
              const DbookSocialLoginRow(
                dividerLabel: 'ou continue com',
                buttons: [
                  DbookSocialLoginButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                  ),
                  DbookSocialLoginButton(icon: Icons.apple, label: 'Apple'),
                ],
              ),
              const SizedBox(height: DbookSpacing.lg),
              TextButton(
                onPressed: widget.onNavigateToRegister,
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
