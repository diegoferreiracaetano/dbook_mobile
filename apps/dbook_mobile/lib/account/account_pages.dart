import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'account_api.dart';

const _languages = {'pt-BR': 'Português', 'en': 'English', 'es': 'Español'};
const _currencies = {
  'BRL': 'Real (BRL)',
  'USD': 'Dólar (USD)',
  'EUR': 'Euro (EUR)',
};
const _cabins = {
  'ECONOMY': 'Econômica',
  'PREMIUM_ECONOMY': 'Econômica premium',
  'BUSINESS': 'Executiva',
  'FIRST': 'Primeira classe',
};
const _seats = {'ANY': 'Tanto faz', 'WINDOW': 'Janela', 'AISLE': 'Corredor'};

String _message(Object error) =>
    error is DbookNetworkException ? error.message : 'Tente de novo.';

/// Preferências de viagem guardadas no servidor: cada escolha vale na hora e
/// volta atrás se o servidor recusar. O aeroporto de origem pré-preenche a
/// busca da Home.
class TravelPreferencesPage extends ConsumerStatefulWidget {
  const TravelPreferencesPage({super.key});

  @override
  ConsumerState<TravelPreferencesPage> createState() =>
      _TravelPreferencesState();
}

class _TravelPreferencesState extends ConsumerState<TravelPreferencesPage> {
  Preferences? _current;
  String? _error;

  Future<void> _save(Preferences next) async {
    final before = _current;
    setState(() {
      _current = next;
      _error = null;
    });
    try {
      final saved = await ref.read(accountApiProvider).savePreferences(next);
      ref.invalidate(preferencesProvider);
      if (mounted) setState(() => _current = saved);
    } on DbookNetworkException catch (error) {
      if (mounted) {
        setState(() {
          _current = before;
          _error = error.message;
        });
      }
    }
  }

  Future<void> _pickAirport(Preferences prefs) async {
    final destinations =
        ref.read(featuredDestinationsProvider).value ?? const [];
    if (destinations.isEmpty) return;
    final picked = await showAirportPickerSheet(context, destinations);
    if (picked != null) {
      await _save(prefs.copyWith(homeAirport: () => picked.iataCode));
    }
  }

  Widget _choice({
    required String title,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String?>(
        value: value,
        hint: const Text('Sem preferência'),
        underline: const SizedBox.shrink(),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Sem preferência'),
          ),
          for (final entry in options.entries)
            DropdownMenuItem<String?>(
              value: entry.key,
              child: Text(entry.value),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(preferencesProvider);
    final prefs = _current ?? loaded.value;

    return Scaffold(
      appBar: const DbookAppBar(title: 'Preferências de viagem'),
      body: prefs == null
          ? loaded.hasError
                ? DbookErrorState(
                    message: _message(loaded.error!),
                    onRetry: () => ref.invalidate(preferencesProvider),
                  )
                : const DbookLoadingIndicator()
          : ListView(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              children: [
                if (_error != null) DbookFieldError(_error!),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Aeroporto de origem'),
                        subtitle: const Text('Já vem preenchido na busca'),
                        trailing: Text(prefs.homeAirport ?? 'Escolher'),
                        onTap: () => _pickAirport(prefs),
                      ),
                      const Divider(height: 1),
                      _choice(
                        title: 'Classe',
                        value: prefs.cabinClass,
                        options: _cabins,
                        onChanged: (v) =>
                            _save(prefs.copyWith(cabinClass: () => v)),
                      ),
                      const Divider(height: 1),
                      _choice(
                        title: 'Assento',
                        value: prefs.seatPreference,
                        options: _seats,
                        onChanged: (v) =>
                            _save(prefs.copyWith(seatPreference: () => v)),
                      ),
                      const Divider(height: 1),
                      _choice(
                        title: 'Moeda',
                        value: prefs.currency,
                        options: _currencies,
                        onChanged: (v) =>
                            _save(prefs.copyWith(currency: () => v)),
                      ),
                      const Divider(height: 1),
                      _choice(
                        title: 'Idioma',
                        value: prefs.language,
                        options: _languages,
                        onChanged: (v) =>
                            _save(prefs.copyWith(language: () => v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Aparelhos com sessão aberta; encerrar um derruba o acesso dele.
class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final format = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: const DbookAppBar(title: 'Dispositivos conectados'),
      body: sessions.when(
        loading: () => const DbookLoadingIndicator(),
        error: (error, _) => DbookErrorState(
          message: _message(error),
          onRetry: () => ref.invalidate(sessionsProvider),
        ),
        data: (list) => list.isEmpty
            ? const DbookEmptyState(
                icon: Icons.devices_outlined,
                title: 'Nenhum dispositivo',
                message: 'Quando você entrar em um aparelho, ele aparece aqui.',
              )
            : ListView(
                padding: const EdgeInsets.all(DbookSpacing.lg),
                children: [
                  for (final session in list)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.smartphone_outlined),
                        title: const Text('Sessão aberta'),
                        subtitle: Text(
                          session.lastActiveAt == null
                              ? 'Atividade recente'
                              : 'Último uso: ${format.format(session.lastActiveAt!.toLocal())}',
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(accountApiProvider)
                                  .endSession(session.id);
                              ref.invalidate(sessionsProvider);
                            } on DbookNetworkException catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.message)),
                                );
                              }
                            }
                          },
                          child: const Text('Encerrar'),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Pede a senha atual e a nova; o servidor encerra todas as sessões depois.
Future<bool> showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final current = TextEditingController();
  final next = TextEditingController();
  String? error;
  final done = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Alterar senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha atual'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova senha (mínimo 8 caracteres)',
              ),
            ),
            if (error != null) DbookFieldError(error!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          DbookButton(
            label: 'Salvar',
            onPressed: () async {
              try {
                await ref
                    .read(accountApiProvider)
                    .changePassword(
                      currentPassword: current.text,
                      newPassword: next.text,
                    );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } on DbookNetworkException catch (e) {
                setState(() => error = e.message);
              }
            },
          ),
        ],
      ),
    ),
  );
  // Os controladores não são descartados aqui: o diálogo ainda os usa durante
  // a animação de saída, e sem ouvintes o coletor de lixo os recolhe.
  return done ?? false;
}

/// Define ou remove a foto do perfil por URL (`https`).
Future<bool> showAvatarDialog(
  BuildContext context,
  WidgetRef ref, {
  String? currentUrl,
}) async {
  final controller = TextEditingController(text: currentUrl ?? '');
  String? error;
  final done = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Foto do perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Endereço da imagem (https)',
              ),
            ),
            if (error != null) DbookFieldError(error!),
          ],
        ),
        actions: [
          if (currentUrl != null)
            TextButton(
              onPressed: () async {
                await ref.read(accountApiProvider).setAvatar(null);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Remover foto'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          DbookButton(
            label: 'Salvar',
            onPressed: () async {
              try {
                await ref
                    .read(accountApiProvider)
                    .setAvatar(controller.text.trim());
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } on DbookNetworkException catch (e) {
                setState(() => error = e.message);
              }
            },
          ),
        ],
      ),
    ),
  );
  return done ?? false;
}
