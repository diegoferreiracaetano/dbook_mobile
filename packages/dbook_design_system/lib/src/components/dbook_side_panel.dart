import 'package:flutter/material.dart';

import '../tokens/dbook_motion.dart';
import '../tokens/dbook_spacing.dart';

/// Abre um painel lateral de detalhe (a ficha de um cliente, de uma reserva)
/// por cima da tela, ancorado à direita. Fecha com `Esc`, no botão de fechar
/// ou tocando fora. Enquanto aberto, o foco do teclado fica preso dentro dele
/// e, ao fechar, volta para o controle que o abriu (é o comportamento da rota
/// modal do Flutter). Em tela estreita ocupa a largura toda.
///
/// Devolve o valor passado a `Navigator.pop`, ou `null` se foi dispensado.
Future<T?> showDbookSidePanel<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder bodyBuilder,
  Widget? footer,
  double width = 480,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar painel',
    barrierColor: Colors.black54,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : DbookMotion.base,
    pageBuilder: (context, _, _) => Align(
      alignment: Alignment.centerRight,
      child: _DbookSidePanel(
        title: title,
        width: width,
        body: bodyBuilder(context),
        footer: footer,
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: DbookMotion.emphasized),
      ),
      child: child,
    ),
  );
}

class _DbookSidePanel extends StatelessWidget {
  const _DbookSidePanel({
    required this.title,
    required this.width,
    required this.body,
    this.footer,
  });

  final String title;
  final double width;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 6,
        child: SizedBox(
          width: width > screenWidth ? screenWidth : width,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DbookSpacing.xl,
                    DbookSpacing.md,
                    DbookSpacing.sm,
                    DbookSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: theme.textTheme.titleLarge),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Fechar painel',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DbookSpacing.xl),
                    child: body,
                  ),
                ),
                if (footer != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(DbookSpacing.lg),
                    child: footer,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
