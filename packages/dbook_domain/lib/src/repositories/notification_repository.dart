import '../entities/app_notification.dart';

/// Porta das notificações do próprio usuário (`/v1/notifications`).
abstract interface class NotificationRepository {
  Future<NotificationPage> list({
    String? cursor,
    int size = 20,
    bool unreadOnly = false,
  });

  Future<int> unreadCount();

  Future<void> markRead(int id);

  Future<void> markAllRead();

  Future<List<NotificationPreference>> preferences();

  /// Muda só os pares enviados e devolve a lista em vigor.
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> changes,
  );

  /// Registra o aparelho para receber *push* (`ANDROID`, `IOS` ou `WEB`).
  Future<void> registerDevice({
    required String token,
    required String platform,
  });

  Future<void> unregisterDevice(String token);
}
