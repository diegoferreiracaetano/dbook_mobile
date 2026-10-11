import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'theme_mode';

/// Aparência escolhida no aparelho: acompanhar o sistema (padrão), claro ou
/// escuro. É preferência do próprio aparelho, não dado de negócio, então fica
/// em `SharedPreferences` e não no servidor.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      final mode = ThemeMode.values.where((m) => m.name == saved);
      if (mode.isNotEmpty) state = mode.first;
    } on Object {
      // Sem armazenamento local: segue o sistema.
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } on Object {
      // A escolha vale nesta sessão mesmo sem conseguir gravar.
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
