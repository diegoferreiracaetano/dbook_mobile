import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'favorite_destination_iata_codes';

/// Destinos favoritados (por código IATA) na grade de "Destinos em
/// destaque" — só local (`shared_preferences`), sem endpoint de favoritos
/// no backend: não é dado que precisa sincronizar entre dispositivos pra
/// fazer sentido nesta fase.
class FavoriteDestinationsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? const []).toSet();
  }

  Future<void> toggle(String iataCode) async {
    final current = state.value ?? const {};
    final updated = Set<String>.of(current);
    if (!updated.remove(iataCode)) updated.add(iataCode);

    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated.toList());
  }
}

final favoriteDestinationsProvider =
    AsyncNotifierProvider<FavoriteDestinationsNotifier, Set<String>>(
      FavoriteDestinationsNotifier.new,
    );
