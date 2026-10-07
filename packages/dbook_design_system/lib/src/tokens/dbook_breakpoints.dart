import 'package:flutter/widgets.dart';

/// Classe de largura da janela, no vocabulário do Material 3.
enum DbookWindowSize { compact, medium, expanded }

/// Larguras (em dp) onde o layout muda. O app de clientes vive em `compact`;
/// o portal começa em `medium` e usa o espaço extra de `expanded`.
abstract final class DbookBreakpoints {
  static const double medium = 600;
  static const double expanded = 1024;

  static DbookWindowSize fromWidth(double width) {
    if (width >= expanded) return DbookWindowSize.expanded;
    if (width >= medium) return DbookWindowSize.medium;
    return DbookWindowSize.compact;
  }

  static DbookWindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
