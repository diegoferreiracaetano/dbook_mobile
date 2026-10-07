import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';

/// Tom do aviso rápido.
enum DbookToastTone { success, info, warning, danger }

/// Aviso rápido no rodapé ("Cliente bloqueado"), com ícone além da cor. Some
/// sozinho; o leitor de tela o anuncia (é um `SnackBar`).
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showDbookToast(
  BuildContext context,
  String message, {
  DbookToastTone tone = DbookToastTone.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(_snackBar(context, message, tone, duration));
}

/// Aviso com "Desfazer". Devolve `true` se o usuário desfez, `false` se o
/// aviso fechou sem ele. **Quem chama confirma a ação só depois**:
///
/// ```dart
/// final undone = await showDbookUndoSnackbar(context, 'Reserva cancelada');
/// if (!undone) await cancelOnServer();
/// ```
Future<bool> showDbookUndoSnackbar(
  BuildContext context,
  String message, {
  String undoLabel = 'Desfazer',
  Duration duration = const Duration(seconds: 6),
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    _snackBar(
      context,
      message,
      DbookToastTone.info,
      duration,
      action: SnackBarAction(label: undoLabel, onPressed: () {}),
    ),
  );
  final reason = await controller.closed;
  return reason == SnackBarClosedReason.action;
}

SnackBar _snackBar(
  BuildContext context,
  String message,
  DbookToastTone tone,
  Duration duration, {
  SnackBarAction? action,
}) {
  final colors = Theme.of(context).extension<DbookStatusColors>()!;
  final (background, foreground, icon) = switch (tone) {
    DbookToastTone.success => (
      colors.successContainer,
      colors.success,
      Icons.check_circle_outline,
    ),
    DbookToastTone.info => (
      colors.infoContainer,
      colors.info,
      Icons.info_outline,
    ),
    DbookToastTone.warning => (
      colors.warningContainer,
      colors.warning,
      Icons.warning_amber_outlined,
    ),
    DbookToastTone.danger => (
      colors.dangerContainer,
      colors.danger,
      Icons.error_outline,
    ),
  };

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: background,
    duration: duration,
    // com ação o Material 3 não fecha sozinho; o desfazer precisa expirar
    persist: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DbookRadius.sm),
    ),
    action: action == null
        ? null
        : SnackBarAction(
            label: action.label,
            textColor: foreground,
            onPressed: action.onPressed,
          ),
    content: Row(
      children: [
        Icon(icon, color: foreground, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(color: foreground)),
        ),
      ],
    ),
  );
}
