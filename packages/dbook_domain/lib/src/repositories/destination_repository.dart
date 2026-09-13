import '../entities/destination.dart';

/// Porta pro catálogo de destinos — implementada de verdade em
/// `dbook_core_network`, com um fake em memória nos testes de widget.
abstract interface class DestinationRepository {
  /// `GET /destinations` — todo destino conhecido, com foto e menor preço
  /// real. Fonte única pra Home, Explore e o seletor de origem/destino da
  /// busca; o app não mantém nenhuma lista própria.
  Future<List<Destination>> getFeaturedDestinations();
}
