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

/// A origem e a data de ida "atuais" do formulário de busca da Home — a
/// única ponte de estado real entre Home e Explore (volta/tipo de
/// viagem/passageiros continuam só da Home; Explore nunca precisa saber
/// disso pra montar uma busca de 1 trecho). Atualizado pela Home sempre
/// que origem ou data de ida mudam; lido por `main.dart` quando o usuário
/// toca um destino no Explore, pra montar uma `FlightSearchQuery` real e
/// já cair em resultados de voo de verdade — nenhum app de referência
/// (Google Flights "Explore", Skyscanner "Explore Everywhere") busca
/// "voos de uma região inteira"; é sempre origem→destino→data.
typedef SearchOrigin = ({Destination origin, DateTime date});

class SearchOriginNotifier extends Notifier<SearchOrigin?> {
  @override
  SearchOrigin? build() => null;

  void set(Destination origin, DateTime date) =>
      state = (origin: origin, date: date);
}

final searchOriginProvider =
    NotifierProvider<SearchOriginNotifier, SearchOrigin?>(
      SearchOriginNotifier.new,
    );

/// Ponte efêmera entre a aba Explore e a busca — só usada como
/// **fallback**, pro caso raro de tocar um destino no Explore antes de
/// `searchOriginProvider` ter uma origem (destinos ainda carregando):
/// não dá pra fabricar uma origem (front burro), então cai de volta no
/// comportamento antigo de só pré-preencher o campo de destino na Home e
/// deixar o usuário buscar na mão. Fora esse caso, `main.dart` já monta a
/// busca direto via `searchOriginProvider` e este provider nem é tocado.
class PrefillDestinationNotifier extends Notifier<Destination?> {
  @override
  Destination? build() => null;

  void set(Destination? destination) => state = destination;
}

final prefillDestinationProvider =
    NotifierProvider<PrefillDestinationNotifier, Destination?>(
      PrefillDestinationNotifier.new,
    );
