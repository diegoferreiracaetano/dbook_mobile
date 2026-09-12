import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/known_airports.dart';
import 'flight_search_notifier.dart';
import 'flight_search_state.dart';

/// Usa o `dioProvider` de `dbook_core_session` — o mesmo Dio autenticado
/// (token + refresh automático) compartilhado com toda outra feature.
final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepositoryImpl(ref.watch(dioProvider)),
);

final flightSearchNotifierProvider =
    NotifierProvider<FlightSearchNotifier, FlightSearchState>(
      FlightSearchNotifier.new,
    );

/// Ponte efêmera entre a aba Explore e a busca: tocar um destino lá seta
/// este provider, a Home lê uma vez (e limpa) pra pré-preencher o campo de
/// destino. Não é estado de busca de verdade — some assim que a Home lê.
class PrefillDestinationNotifier extends Notifier<KnownAirport?> {
  @override
  KnownAirport? build() => null;

  void set(KnownAirport? destination) => state = destination;
}

final prefillDestinationProvider =
    NotifierProvider<PrefillDestinationNotifier, KnownAirport?>(
      PrefillDestinationNotifier.new,
    );
