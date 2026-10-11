/// O que aconteceu. Espelha `NotificationType` do backend; um tipo novo que o
/// app ainda não conhece é `unknown` (aparece na caixa de entrada, sem atalho).
enum NotificationType {
  bookingConfirmed,
  bookingExpired,
  bookingCancelledByStaff,
  refundCompleted,
  flightChanged,
  priceAlert,
  unknown,
}

enum NotificationChannel { inApp, email, push }

/// Para onde levar a pessoa ao tocar na notificação. Todas as notificações de
/// hoje (reserva, reembolso, mudança de voo) falam de uma viagem dela.
enum NotificationTarget { trips, priceAlerts, none }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.data = const {},
  });

  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  /// Os dados do evento (`bookingId`, `flightId`...), como o servidor mandou.
  final Map<String, dynamic> data;

  NotificationTarget get target => switch (type) {
    NotificationType.unknown => NotificationTarget.none,
    NotificationType.priceAlert => NotificationTarget.priceAlerts,
    _ => NotificationTarget.trips,
  };

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    read: true,
    createdAt: createdAt,
    data: data,
  );
}

class NotificationPage {
  const NotificationPage({required this.items, this.nextCursor});

  final List<AppNotification> items;
  final String? nextCursor;
}

/// Um par tipo × canal ligado ou desligado.
class NotificationPreference {
  const NotificationPreference({
    required this.type,
    required this.channel,
    required this.enabled,
  });

  final NotificationType type;
  final NotificationChannel channel;
  final bool enabled;

  NotificationPreference copyWith({bool? enabled}) => NotificationPreference(
    type: type,
    channel: channel,
    enabled: enabled ?? this.enabled,
  );
}
