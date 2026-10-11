import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/notification_providers.dart';

/// O sino com o selo de não lidas. O número vem do servidor; se a consulta
/// falha, o sino aparece sem selo (não inventa contagem).
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return IconButton(
      tooltip: unread > 0 ? 'Notificações ($unread não lidas)' : 'Notificações',
      onPressed: onPressed,
      icon: DbookNotificationBadge(
        count: unread,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
