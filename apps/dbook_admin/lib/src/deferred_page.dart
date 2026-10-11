import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

/// Carrega uma tela pesada (a do painel traz a biblioteca de gráficos) só
/// quando a rota é aberta (`deferred as`), para o primeiro carregamento do
/// portal não pagar por ela. Enquanto baixa mostra o indicador; se a rede
/// falha, oferece "Tentar de novo".
class DeferredPage extends StatefulWidget {
  const DeferredPage({super.key, required this.load, required this.builder});

  /// `library.loadLibrary` de um `import ... deferred as library`.
  final Future<void> Function() load;
  final WidgetBuilder builder;

  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  late Future<void> _loading = widget.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DbookErrorState(
            message: context.l10n.errNetwork,
            onRetry: () => setState(() => _loading = widget.load()),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const DbookLoadingIndicator();
        }
        return widget.builder(context);
      },
    );
  }
}
