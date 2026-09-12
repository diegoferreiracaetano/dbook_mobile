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
/// [logoutAction] e [myBookingsAction] aparecem como ações na app bar da
/// tela de busca, [onBookFlight] dispara no botão "Book This Flight" do
/// detalhe e [liveAvailabilityBuilder] monta o indicador de disponibilidade
/// ao vivo pro voo do detalhe — a feature de voos não conhece
/// `AuthNotifier` nem as features de reserva/tempo real (features não
/// importam features), então quem monta essa tela (o app) decide o que
/// cada uma faz.
class FlightsHomePage extends StatefulWidget {
  const FlightsHomePage({
    super.key,
    this.logoutAction,
    this.myBookingsAction,
    this.onBookFlight,
    this.liveAvailabilityBuilder,
  });

  final Widget? logoutAction;
  final Widget? myBookingsAction;
  final ValueChanged<Flight>? onBookFlight;
  final Widget Function(Flight flight)? liveAvailabilityBuilder;

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
          actions: [
            if (widget.myBookingsAction != null) widget.myBookingsAction!,
            if (widget.logoutAction != null) widget.logoutAction!,
          ],
          onSearch: (query) => context.push('/results', extra: query),
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
