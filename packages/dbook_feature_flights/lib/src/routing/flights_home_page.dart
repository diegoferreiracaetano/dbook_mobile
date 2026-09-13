import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../ui/flight_detail_page.dart';
import '../ui/flight_results_page.dart';
import '../ui/flight_search_page.dart';

/// Busca → resultados → detalhe, com rotas de verdade (`go_router`) em vez
/// de um `Navigator` cru — dá deep link e histórico de rota de graça pra
/// quando o app crescer. Fica isolado num `Router` próprio (não precisa de
/// um segundo `MaterialApp`: o app raiz já provê tema/Directionality).
///
/// [actions] aparece no cabeçalho da tela de busca (raiz desta rota),
/// [onBookFlight] dispara no botão "Book This Flight" do detalhe,
/// [liveAvailabilityBuilder] monta o indicador de disponibilidade ao vivo
/// pro voo do detalhe e [onQueueLegs] avisa o app sobre trechos extras de
/// uma busca Multi-city (o 1º trecho sempre segue pela rota `/results`
/// normal abaixo; do 2º em diante não tem como usar o `go_router` interno
/// — moram fora dessa aba, na jornada de reserva) — a feature de voos não
/// conhece `AuthNotifier` nem as features de reserva/tempo real/sugestão
/// por IA (features não importam features), então quem monta essa tela (o
/// app) decide o que cada uma faz.
class FlightsHomePage extends StatefulWidget {
  const FlightsHomePage({
    super.key,
    this.actions,
    this.onBookFlight,
    this.liveAvailabilityBuilder,
    this.onQueueLegs,
    this.onSelectRegion,
  });

  final List<Widget>? actions;
  final ValueChanged<Flight>? onBookFlight;
  final Widget Function(Flight flight)? liveAvailabilityBuilder;
  final ValueChanged<List<FlightSearchQuery>>? onQueueLegs;

  /// Repassado direto pro carrossel de regiões da tela de busca — ver
  /// `FlightSearchPage.onSelectRegion`.
  final ValueChanged<String>? onSelectRegion;

  @override
  State<FlightsHomePage> createState() => _FlightsHomePageState();
}

class _FlightsHomePageState extends State<FlightsHomePage> {
  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => FlightSearchPage(
          actions: widget.actions,
          onSelectRegion: widget.onSelectRegion,
          onSearch: (queries) {
            widget.onQueueLegs?.call(queries.skip(1).toList());
            context.push('/results', extra: queries.first);
          },
        ),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => FlightResultsPage(
          query: state.extra! as FlightSearchQuery,
          onSelectFlight: (flight) =>
              context.push('/results/detail', extra: flight),
        ),
      ),
      GoRoute(
        path: '/results/detail',
        builder: (context, state) {
          final flight = state.extra! as Flight;
          return FlightDetailPage(
            flight: flight,
            onBook: widget.onBookFlight,
            liveAvailability: widget.liveAvailabilityBuilder?.call(flight),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Router.withConfig(config: _router);
}
