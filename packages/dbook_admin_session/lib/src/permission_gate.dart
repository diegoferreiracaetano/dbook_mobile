import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_providers.dart';

/// Mostra [child] só para quem tem a [permission]; para os demais, [fallback]
/// (nada, por padrão). É conveniência de tela: quem barra de verdade é o
/// servidor.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final Permission permission;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(canProvider(permission)) ? child : fallback;
}
