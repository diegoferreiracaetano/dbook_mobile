import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inbox_notifier.dart';
import 'preferences_notifier.dart';
import 'push_token_source.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(dioProvider)),
);

/// O número do selo do sino; quem muda a caixa de entrada o invalida.
final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);

final inboxNotifierProvider =
    NotifierProvider.autoDispose<InboxNotifier, InboxState>(InboxNotifier.new);

final preferencesNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      PreferencesNotifier,
      List<NotificationPreference>
    >(PreferencesNotifier.new);

/// Hoje o adaptador falso; o FCM real troca só este provider.
final pushTokenSourceProvider = Provider<PushTokenSource>(
  (ref) => FakePushTokenSource(),
);

/// Registra o aparelho no servidor depois do login e o remove no logout.
class DeviceRegistrar {
  DeviceRegistrar(this._ref);

  final Ref _ref;
  String? _registered;

  Future<void> register() async {
    try {
      final token = await _ref.read(pushTokenSourceProvider).token();
      if (token == null || token == _registered) return;
      await _ref
          .read(notificationRepositoryProvider)
          .registerDevice(
            token: token,
            platform: _ref.read(appClientProvider).platform,
          );
      _registered = token;
    } on Object {
      // Registrar o aparelho é um extra: não pode atrapalhar o login.
    }
  }

  Future<void> unregister() async {
    final token = _registered;
    if (token == null) return;
    _registered = null;
    try {
      await _ref.read(notificationRepositoryProvider).unregisterDevice(token);
    } on Object {
      // Sair sempre funciona; o servidor limpa o token na próxima vez.
    }
  }
}

final deviceRegistrarProvider = Provider<DeviceRegistrar>(DeviceRegistrar.new);
