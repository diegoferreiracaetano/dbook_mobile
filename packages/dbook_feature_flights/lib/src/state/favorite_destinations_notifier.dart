import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'destination_reviews_notifier.dart' show isLoggedInProvider;

/// Onde ficavam os favoritos antes de irem para o servidor (só no aparelho).
const _legacyKey = 'favorite_destination_iata_codes';

/// Cópia de leitura do que o servidor devolveu: serve só para a grade já
/// nascer marcada enquanto a resposta chega. **Nunca** é a verdade.
const _cacheKey = 'favorite_destination_cache';
const _migratedKey = 'favorites_migrated_to_server';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepositoryImpl(ref.watch(dioProvider)),
);

/// Destinos favoritos (códigos IATA). **O servidor é a fonte da verdade**
/// (`/v1/favorites`): ao entrar, a lista dele vence e o cache local só
/// antecipa a tela. Favoritar e desfavoritar aparecem na hora e **voltam
/// atrás** se o servidor recusar (sem rede, limite de 200...), e o erro sobe
/// para a tela explicar: **nada vai para uma fila silenciosa** que
/// sincronizaria mais tarde sem a pessoa saber.
class FavoriteDestinationsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.watch(isLoggedInProvider)) {
      // sem sessão não há favoritos, e o cache de uma conta não pode vazar
      // para quem usa o aparelho depois
      await prefs.remove(_cacheKey);
      return const {};
    }
    Future<void>.microtask(_sync);
    return (prefs.getStringList(_cacheKey) ?? const []).toSet();
  }

  Future<void> _sync() async {
    final repository = ref.read(favoriteRepositoryProvider);
    try {
      await _migrateLegacy(repository);
      final server = await repository.destinations();
      state = AsyncData(server);
      await _saveCache(server);
    } on Object {
      // sem resposta: fica o cache; a próxima abertura tenta de novo
    }
  }

  /// A migração **única** dos favoritos que só existiam no aparelho: envia
  /// cada um ao servidor (`PUT` é idempotente, então repetir é inofensivo),
  /// confere que ele os tem, e **só então** apaga a cópia antiga e marca como
  /// migrado. Se algo falha no meio, nada é apagado e a próxima abertura
  /// refaz. Um destino que o servidor desconhece (`404`) é descartado.
  Future<void> _migrateLegacy(FavoriteRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) ?? false) return;
    final legacy = (prefs.getStringList(_legacyKey) ?? const []).toSet();

    if (legacy.isNotEmpty) {
      final accepted = <String>{};
      for (final code in legacy) {
        try {
          await repository.addDestination(code);
          accepted.add(code);
        } on DbookNotFoundException {
          // o destino não existe mais no catálogo: não há o que migrar
        }
      }
      final onServer = await repository.destinations();
      // só apaga a cópia antiga se o servidor confirma ter tudo o que aceitou
      if (!accepted.every(onServer.contains)) return;
    }
    await prefs.remove(_legacyKey);
    await prefs.setBool(_migratedKey, true);
  }

  Future<void> _saveCache(Set<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey, codes.toList());
  }

  /// Liga ou desliga um destino. Deixa o `DbookNetworkException` subir depois
  /// de desfazer a mudança na tela.
  Future<void> toggle(String iataCode) async {
    final before = state.value ?? const <String>{};
    final adding = !before.contains(iataCode);
    final after = Set<String>.of(before);
    adding ? after.add(iataCode) : after.remove(iataCode);

    state = AsyncData(after);
    final repository = ref.read(favoriteRepositoryProvider);
    try {
      if (adding) {
        await repository.addDestination(iataCode);
      } else {
        await repository.removeDestination(iataCode);
      }
      await _saveCache(after);
    } on Object {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final favoriteDestinationsProvider =
    AsyncNotifierProvider<FavoriteDestinationsNotifier, Set<String>>(
      FavoriteDestinationsNotifier.new,
    );
