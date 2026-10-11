import 'package:dbook_domain/dbook_domain.dart';

String notificationTypeLabel(NotificationType type) => switch (type) {
  NotificationType.bookingConfirmed => 'Reserva confirmada',
  NotificationType.bookingExpired => 'Reserva expirada',
  NotificationType.bookingCancelledByStaff => 'Reserva cancelada pela equipe',
  NotificationType.refundCompleted => 'Reembolso concluído',
  NotificationType.flightChanged => 'Mudança no voo',
  NotificationType.priceAlert => 'Alerta de preço',
  NotificationType.unknown => 'Outros avisos',
};

String notificationChannelLabel(NotificationChannel channel) =>
    switch (channel) {
      NotificationChannel.inApp => 'No app',
      NotificationChannel.email => 'E-mail',
      NotificationChannel.push => 'Notificação no celular',
    };
