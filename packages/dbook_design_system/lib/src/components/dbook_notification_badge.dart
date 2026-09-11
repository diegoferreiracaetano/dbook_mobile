import 'package:flutter/material.dart';

/// Badge numérico sobreposto a um ícone (ex. contador de notificação no
/// Drawer/Menu) — tema vem de `badgeTheme`; some sozinho quando [count] é
/// zero, diferente do [Badge] nativo que sempre desenha um ponto.
class DbookNotificationBadge extends StatelessWidget {
  const DbookNotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Badge(label: Text('$count'), child: child);
  }
}
