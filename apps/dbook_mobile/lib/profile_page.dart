import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Perfil do usuário autenticado — avatar com iniciais, nome e e-mail reais
/// (populados em `AuthState` por `AuthNotifier` via `GET /users/me`),
/// "Editar Perfil" (`PATCH /users/me`) e Sair. Só mostra o que tem dado ou
/// ação real por trás — sem os itens decorativos de referência (Travel
/// Documents, Payment Methods etc.) que não têm tela nem dado por trás.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final email = authState is AuthLoggedIn ? authState.email : null;
    final name = authState is AuthLoggedIn ? authState.name : null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              DbookSpacing.lg,
              DbookSpacing.xl,
              DbookSpacing.lg,
              DbookSpacing.xl,
            ),
            color: colorScheme.primary,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  DbookAvatar(
                    size: DbookAvatarSize.large,
                    initials: _initialsOf(name),
                  ),
                  const SizedBox(height: DbookSpacing.sm),
                  Text(
                    (name == null || name.isEmpty)
                        ? 'Sessão sem nome salvo'
                        : name,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    email ?? 'Sessão sem e-mail salvo',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DbookSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DbookButton(
                  label: 'Editar Perfil',
                  variant: DbookButtonVariant.secondary,
                  onPressed: () => _editName(context, currentName: name ?? ''),
                ),
                const SizedBox(height: DbookSpacing.sm),
                DbookButton(
                  label: 'Sair',
                  variant: DbookButtonVariant.text,
                  onPressed: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsOf(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Future<void> _editName(
    BuildContext context, {
    required String currentName,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditNameDialog(currentName: currentName),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil atualizado')));
    }
  }
}

/// Diálogo de edição do nome — chama `AuthNotifier.updateName`, que já
/// atualiza `AuthState` (e portanto a tela por trás) quando der certo.
class _EditNameDialog extends ConsumerStatefulWidget {
  const _EditNameDialog({required this.currentName});

  final String currentName;

  @override
  ConsumerState<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<_EditNameDialog> {
  late final _controller = TextEditingController(text: widget.currentName);
  final _formKey = GlobalKey<FormState>();
  var _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .updateName(_controller.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on DbookNetworkException catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: AuthValidators.name,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: DbookSpacing.sm),
              DbookInlineStatusBanner(
                message: _errorMessage!,
                tone: DbookBannerTone.warning,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        DbookButton(
          label: 'Salvar',
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _submit,
        ),
      ],
    );
  }
}
