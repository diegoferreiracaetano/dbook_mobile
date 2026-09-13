import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flight_search_notifier.dart';
import 'flight_search_state.dart';

/// Usa o `dioProvider` de `dbook_core_session` — o mesmo Dio autenticado
/// (token + refresh automático) compartilhado com toda outra feature.
final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepositoryImpl(ref.watch(dioProvider)),
);

final destinationRepositoryProvider = Provider<DestinationRepository>(
  (ref) => DestinationRepositoryImpl(ref.watch(dioProvider)),
);

final flightSearchNotifierProvider =
    NotifierProvider<FlightSearchNotifier, FlightSearchState>(
      FlightSearchNotifier.new,
    );

/// Todo destino conhecido (`GET /destinations`), com foto e menor preço
/// real — fonte única pra Home, Explore e o seletor de origem/destino da
/// busca. O app não mantém nenhuma lista própria de aeroportos.
final featuredDestinationsProvider = FutureProvider<List<Destination>>(
  (ref) => ref.watch(destinationRepositoryProvider).getFeaturedDestinations(),
);

/// Ponte efêmera entre a aba Explore e a busca: tocar um destino lá seta
/// este provider, a Home lê uma vez (e limpa) pra pré-preencher o campo de
/// destino. Não é estado de busca de verdade — some assim que a Home lê.
class PrefillDestinationNotifier extends Notifier<Destination?> {
  @override
  Destination? build() => null;

  void set(Destination? destination) => state = destination;
}

final prefillDestinationProvider =
    NotifierProvider<PrefillDestinationNotifier, Destination?>(
      PrefillDestinationNotifier.new,
    );

/// Mesma ponte efêmera de [PrefillDestinationNotifier], só que pra região:
/// tocar um card do carrossel de regiões na Home seta este provider, a
/// Explore lê uma vez (e limpa) pra pré-selecionar o filtro da região
/// tocada.
class PrefillRegionNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? region) => state = region;
}

final prefillRegionProvider =
    NotifierProvider<PrefillRegionNotifier, String?>(PrefillRegionNotifier.new);
