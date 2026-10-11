import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_notifications/dbook_feature_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'account/account_api.dart';
import 'account/account_pages.dart';
import 'session_actions.dart';
import 'theme_mode.dart';

/// Versão do app instalada (só para a seção "Sobre"); `null` quando a
/// plataforma não informa, e então a linha some.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } on Object {
    return null;
  }
});

/// Perfil do usuário autenticado, em seções: identidade (avatar com iniciais,
/// nome, e-mail), resumo com números reais (viagens, favoritos, alertas),
/// preferências (notificações e aparência), conta, privacidade e sobre. Só há
/// o que tem dado ou ação real por trás: a foto de perfil e outros dados
/// pessoais dependem de campos que o servidor ainda não tem (CHECKLIST M48).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final email = authState is AuthLoggedIn ? authState.email : null;
    final name = authState is AuthLoggedIn ? authState.name : null;
    final brand = Theme.of(context).extension<DbookBrandColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final version = ref.watch(appVersionProvider).value;
    final account = ref.watch(accountSummaryProvider).value;
    final avatarUrl = account?.avatarUrl;
    final since = account?.createdAt;

    String count(int? value) => value == null ? '–' : '$value';
    final trips = ref.watch(myBookingsNotifierProvider).value?.length;
    final favorites = ref.watch(favoriteDestinationsProvider).value?.length;
    final alerts = ref.watch(priceAlertsNotifierProvider).value?.length;

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
            color: brand.surface,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final changed = await showAvatarDialog(
                        context,
                        ref,
                        currentUrl: avatarUrl,
                      );
                      if (changed) ref.invalidate(accountSummaryProvider);
                    },
                    child: DbookAvatar(
                      size: DbookAvatarSize.large,
                      image: avatarUrl == null ? null : NetworkImage(avatarUrl),
                      initials: _initialsOf(name),
                      backgroundColor: brand.onSurface,
                      foregroundColor: brand.surface,
                    ),
                  ),
                  const SizedBox(height: DbookSpacing.sm),
                  Text(
                    name ?? 'Sessão sem nome salvo',
                    style: textTheme.titleLarge?.copyWith(
                      color: brand.onSurface,
                    ),
                  ),
                  Text(
                    email ?? 'Sessão sem e-mail salvo',
                    style: textTheme.bodyMedium?.copyWith(
                      color: brand.onSurfaceMuted,
                    ),
                  ),
                  if (since != null)
                    Text(
                      'Membro desde ${since.month.toString().padLeft(2, '0')}/${since.year}',
                      style: textTheme.bodySmall?.copyWith(
                        color: brand.onSurfaceMuted,
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
                Row(
                  children: [
                    _StatTile(label: 'Viagens', value: count(trips)),
                    const SizedBox(width: DbookSpacing.sm),
                    _StatTile(label: 'Favoritos', value: count(favorites)),
                    const SizedBox(width: DbookSpacing.sm),
                    _StatTile(label: 'Alertas', value: count(alerts)),
                  ],
                ),
                const SizedBox(height: DbookSpacing.xl),
                const DbookSectionLabel(text: 'Preferências'),
                const SizedBox(height: DbookSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _ProfileRow(
                        icon: Icons.tune_outlined,
                        label: 'Preferências de viagem',
                        onTap: () =>
                            _open(context, const TravelPreferencesPage()),
                      ),
                      const Divider(height: 1),
                      _ProfileRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notificações',
                        onTap: () =>
                            _open(context, const NotificationPreferencesPage()),
                      ),
                      const Divider(height: 1),
                      _ProfileRow(
                        icon: Icons.notifications_active_outlined,
                        label: 'Alertas de preço',
                        onTap: () => _open(context, const PriceAlertsPage()),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(DbookSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aparência', style: theme.textTheme.bodyLarge),
                            const SizedBox(height: DbookSpacing.sm),
                            SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text('Sistema'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  label: Text('Claro'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  label: Text('Escuro'),
                                ),
                              ],
                              selected: {themeMode},
                              onSelectionChanged: (selection) => ref
                                  .read(themeModeProvider.notifier)
                                  .set(selection.first),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DbookSpacing.xl),
                const DbookSectionLabel(text: 'Conta'),
                const SizedBox(height: DbookSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _ProfileRow(
                        icon: Icons.edit_outlined,
                        label: 'Editar perfil',
                        onTap: () =>
                            _editName(context, currentName: name ?? ''),
                      ),
                      const Divider(height: 1),
                      _ProfileRow(
                        icon: Icons.lock_outline,
                        label: 'Alterar senha',
                        onTap: () async {
                          final changed = await showChangePasswordDialog(
                            context,
                            ref,
                          );
                          if (changed && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senha alterada. Entre de novo.'),
                              ),
                            );
                            signOutLocally(ref);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileRow(
                        icon: Icons.devices_outlined,
                        label: 'Dispositivos conectados',
                        onTap: () => _open(context, const DevicesPage()),
                      ),
                      const Divider(height: 1),
                      _ProfileRow(
                        icon: Icons.download_outlined,
                        label: 'Exportar meus dados',
                        onTap: () => showExportMyDataDialog(context),
                      ),
                    ],
                  ),
                ),
                if (version != null) ...[
                  const SizedBox(height: DbookSpacing.xl),
                  const DbookSectionLabel(text: 'Sobre'),
                  const SizedBox(height: DbookSpacing.sm),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Versão do app'),
                      trailing: Text(version, style: textTheme.bodyMedium),
                    ),
                  ),
                ],
                const SizedBox(height: DbookSpacing.xl),
                DbookButton(
                  label: 'Sair',
                  variant: DbookButtonVariant.secondary,
                  onPressed: () => signOut(ref),
                ),
                const SizedBox(height: DbookSpacing.xl),
                // Ação destrutiva: separada do resto, em cor de perigo, sem
                // o mesmo peso de "Sair".
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    minimumSize: const Size.fromHeight(
                      DbookSizes.controlHeight,
                    ),
                  ),
                  onPressed: () => showDeleteAccountDialog(
                    context,
                    onDeleted: () => signOutLocally(ref),
                  ),
                  child: const Text('Excluir minha conta'),
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
      title: const Text('Editar perfil'),
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

/// Uma linha de ação do perfil: ícone, rótulo e seta. Agrupa as ações num
/// cartão só, em vez de uma pilha de botões do mesmo peso.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

/// Um número do resumo do perfil.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DbookSpacing.md),
          child: Column(
            children: [
              Text(value, style: theme.textTheme.titleLarge),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
