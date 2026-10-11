import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_providers.dart';

/// Preferências por tipo e canal. Ligar ou desligar vale **na hora** na
/// tela; o servidor confirma depois, e se recusar a chave **volta** ao que
/// era e o erro sobe para a tela avisar.
class PreferencesNotifier extends AsyncNotifier<List<NotificationPreference>> {
  @override
  Future<List<NotificationPreference>> build() =>
      ref.read(notificationRepositoryProvider).preferences();

  Future<void> set(
    NotificationType type,
    NotificationChannel channel, {
    required bool enabled,
  }) async {
    final before = state.value;
    if (before == null) return;

    List<NotificationPreference> applied(List<NotificationPreference> list) => [
      for (final p in list)
        p.type == type && p.channel == channel
            ? p.copyWith(enabled: enabled)
            : p,
    ];

    state = AsyncData(applied(before));
    try {
      final confirmed = await ref
          .read(notificationRepositoryProvider)
          .updatePreferences([
            NotificationPreference(
              type: type,
              channel: channel,
              enabled: enabled,
            ),
          ]);
      if (confirmed.isNotEmpty) state = AsyncData(confirmed);
    } on Object {
      state = AsyncData(before);
      rethrow;
    }
  }
}
