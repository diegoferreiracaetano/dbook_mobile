import 'dart:io';

import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_ai/dbook_feature_ai.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_notifications/dbook_feature_notifications.dart';
import 'package:dbook_feature_realtime/dbook_feature_realtime.dart';
import 'package:dbook_feature_stays/dbook_feature_stays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_blocked_gate.dart';
import 'account/account_api.dart';
import 'app_update_gate.dart';
import 'home_stays_section.dart';
import 'profile_page.dart';
import 'theme_mode.dart';
import 'session_actions.dart';

/// Versão da API de negócio que este app fala. Todos os repositórios usam
/// caminhos relativos (`/bookings`...) sobre esta base, então trocar de
/// versão é trocar só isto. O WebSocket (`/ws`) não tem versão: a URL dele
/// só reaproveita host e porta da base (ver `dbook_live_availability.dart`).
const _apiVersionPath = '/v1';

/// Backend rodando localmente na máquina host: emulador Android enxerga o
/// host via `10.0.2.2`; todo o resto (iOS simulator, web, desktop) enxerga
/// via `localhost` normalmente.
String get _localApiBaseUrl {
  final host = !kIsWeb && Platform.isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:8080$_apiVersionPath';
}

/// Plataforma no vocabulário do servidor (`X-App-Platform`); o que ele não
/// conhece vira `unknown` do lado dele.
String get _appPlatform {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'unknown',
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final package = await PackageInfo.fromPlatform();

  runApp(
    ProviderScope(
      overrides: [
        // a ponte entre features: as avaliações do destino precisam saber
        // quais são "minhas" (vêm das reservas) e se há sessão
        ownReviewIdsProvider.overrideWith(
          (ref) => {
            for (final booking
                in ref.watch(myBookingsNotifierProvider).value ??
                    const <MyBooking>[])
              if (booking.review != null) booking.review!.id,
          },
        ),
        isLoggedInProvider.overrideWith(
          (ref) => ref.watch(authNotifierProvider) is AuthLoggedIn,
        ),
        baseUrlProvider.overrideWithValue(_localApiBaseUrl),
        dbookNetworkLoggingProvider.overrideWithValue(kDebugMode),
        appClientProvider.overrideWithValue(
          AppClientInfo(
            version: '${package.version}+${package.buildNumber}',
            platform: _appPlatform,
          ),
        ),
      ],
      child: const DbookMobileApp(),
    ),
  );
}

class DbookMobileApp extends ConsumerWidget {
  const DbookMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'DBook',
      theme: DbookTheme.light,
      darkTheme: DbookTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) => AccountBlockedGate(
        child: AppUpdateGate(child: child ?? const SizedBox.shrink()),
      ),
      home: const _AppRoot(),
    );
  }
}

const _hasOnboardedPrefsKey = 'has_onboarded';

/// Só decide 2 coisas, nenhuma delas é "o usuário está logado?" (M9-9.1):
/// se já passou pelo onboarding (uma vez só, guardado localmente) e, se
/// não, mostra ele. Depois disso é sempre o shell — busca é pública
/// (`GET /flights/search` não exige sessão), então não há motivo pra
/// travar a primeira tela nisso. O bootstrap de sessão roda em paralelo,
/// sem bloquear: só afeta se o shell já nasce "logado" ou não.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool? _hasOnboarded;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
    // Riverpod não permite mudar o estado de um provider durante o build da
    // árvore de widgets — adia pro fim do primeiro frame. Não é aguardado:
    // a Home não espera a sessão resolver pra aparecer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).bootstrap();
    });
  }

  Future<void> _loadOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _hasOnboarded = prefs.getBool(_hasOnboardedPrefsKey) ?? false,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasOnboardedPrefsKey, true);
    if (mounted) setState(() => _hasOnboarded = true);
  }

  @override
  Widget build(BuildContext context) {
    final hasOnboarded = _hasOnboarded;
    if (hasOnboarded == null) {
      return const Scaffold(body: DbookLoadingIndicator());
    }
    if (!hasOnboarded) {
      return OnboardingPage(onFinished: _completeOnboarding);
    }
    return const _AppShell();
  }
}

/// Empurra login/cadastro na Navigator raiz (fora do `Router` interno de
/// qualquer feature) e, ao autenticar, volta pra rota de origem e empurra
/// [onAuthenticated] (quando informado — sem destino, só volta pra origem,
/// caso do botão avulso "Entrar") — nunca deixa login/cadastro no
/// back-stack e nunca devolve pra Home (M9-9.1: mesmo se o usuário passar
/// por login *e depois* cadastro no meio do caminho, o back-stack final é
/// só origem→destino).
void pushAuthGate(BuildContext context, {WidgetBuilder? onAuthenticated}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  final origin = ModalRoute.of(context);

  void goToDestination() {
    navigator.popUntil((route) => route == origin || route.isFirst);
    if (onAuthenticated != null) {
      navigator.push(MaterialPageRoute<void>(builder: onAuthenticated));
    }
  }

  navigator.push(
    MaterialPageRoute<void>(
      builder: (context) => LoginPage(
        onLoggedIn: goToDestination,
        onNavigateToRegister: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (context) => RegisterPage(
              onRegistered: goToDestination,
              onNavigateToLogin: () => navigator.pop(),
            ),
          ),
        ),
      ),
    ),
  );
}

/// O shell sempre visível depois do onboarding — 4 abas fixas (Home,
/// Explore, Trips, Profile), visíveis pra visitante e usuário logado. Nem
/// a feature de voos, nem a de reserva, nem a de auth se conhecem
/// (features não importam features), então é o app que decide: ações que
/// exigem sessão (reservar, Trips, Profile, "Ask DBook AI" — o backend
/// exige auth em `POST /ai/suggestions`) passam pelo Auth Gate quando não
/// há sessão. Trips/Profile continuam na barra pra visitante (em vez de
/// sumir por sessão) — mostram um placeholder com CTA "Entrar", mais
/// previsível que trocar o conjunto de abas dependendo do login.
class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _tabIndex = 0;

  /// Trechos 2+ de uma busca Round Trip/Multi-city — populado quando a
  /// Home dispara [FlightsHomePage.onQueueLegs] (1º trecho segue pelo
  /// fluxo normal via `go_router` interno da Home). Consumido em
  /// [_selectFlight] pra saber se ainda falta escolher o voo de outro
  /// trecho antes de ir pra seleção de assento.
  List<FlightSearchQuery> _pendingLegs = [];

  static void _openAiSuggestions(
    BuildContext context, {
    required bool isLoggedIn,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (isLoggedIn) {
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const AiSuggestionPage()),
      );
      return;
    }
    // Visitante: explica antes de levar ao login (a IA usa a conta para limitar
    // o uso), em vez de cair numa tela de login sem contexto.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Entre para perguntar à IA'),
        content: const Text(
          'A IA sugere voos reais a partir do seu pedido. Para usar, entre na '
          'sua conta ou crie uma: é rápido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Agora não'),
          ),
          DbookButton(
            label: 'Entrar',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              pushAuthGate(
                context,
                onAuthenticated: (_) => const AiSuggestionPage(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Nem Round Trip nem Multi-city são "1 trecho de verdade + resto
  /// decorativo": o backend não tem conceito de reserva multi-trecho
  /// (`POST /bookings` é sempre 1 voo), então cada trecho vira uma compra
  /// real e independente. A ORDEM da jornada é: escolhe o voo de CADA
  /// trecho primeiro (ida, depois volta/extras — sem passar por seleção
  /// de assento ainda); só depois que o último voo é escolhido é que a
  /// seleção de assento começa, um trecho de cada vez, encadeada por
  /// [_buildSeatSelectionFor]. [chosenFlights] acumula os voos já
  /// escolhidos, na ordem; [remainingLegs] é o que ainda falta escolher.
  static void _selectFlight(
    BuildContext context,
    Flight flight, {
    required bool isLoggedIn,
    List<Flight> chosenFlights = const [],
    List<FlightSearchQuery> remainingLegs = const [],
  }) {
    final updatedChosen = [...chosenFlights, flight];

    Widget buildNext(BuildContext _) {
      if (remainingLegs.isNotEmpty) {
        return _buildResultsPage(
          context,
          remainingLegs.first,
          remainingLegs.skip(1).toList(),
          chosenFlights: updatedChosen,
          isLoggedIn: true,
        );
      }
      return _buildSeatSelectionFor(context, updatedChosen, 0);
    }

    if (isLoggedIn) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute<void>(builder: buildNext));
      return;
    }
    pushAuthGate(context, onAuthenticated: buildNext);
  }

  /// Resultados do próximo trecho ainda sem voo escolhido — direto no root
  /// navigator (fora do `go_router` interno da `FlightsHomePage`, que só
  /// existe dentro da aba Home), reaproveitando `FlightResultsPage`/
  /// `FlightDetailPage` com `Navigator.push` comum. [isLoggedIn] vem de
  /// quem chama: `true` na jornada normal (só se chega aqui depois do
  /// gate de autenticação na 1ª escolha) e o valor real da sessão quando
  /// reaproveitada por [_openExploreDestination] (convidado pode tocar um
  /// destino no Explore sem estar logado).
  static Widget _buildResultsPage(
    BuildContext context,
    FlightSearchQuery query,
    List<FlightSearchQuery> remainingAfter, {
    required List<Flight> chosenFlights,
    required bool isLoggedIn,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    return FlightResultsPage(
      query: query,
      onSelectFlight: (flight) => navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => FlightDetailPage(
            flight: flight,
            onBook: (selected) => _selectFlight(
              context,
              selected,
              isLoggedIn: isLoggedIn,
              chosenFlights: chosenFlights,
              remainingLegs: remainingAfter,
            ),
            liveAvailability: DbookLiveAvailability(
              bookableId: flight.id,
              fallbackCapacity: flight.availableCapacity,
            ),
          ),
        ),
      ),
    );
  }

  /// Seleção de assento do voo `flights[index]`, encadeada pro próximo em
  /// SILÊNCIO — sem tela de sucesso por trecho, já que o assento agora é
  /// só um detalhe dentro da revisão final ([PaymentPage]), não uma
  /// confirmação própria. [bookedLegs] acumula cada trecho já reservado
  /// (voo+assento+booking); quando o último é reservado, troca pela
  /// revisão + pagamento cobrindo todos de uma vez.
  static Widget _buildSeatSelectionFor(
    BuildContext context,
    List<Flight> flights,
    int index, {
    List<BookedLeg> bookedLegs = const [],
  }) {
    final flight = flights[index];

    return SeatSelectionPage(
      flight: flight,
      onBooked: (booking, bookedFlight, seat) {
        final updatedLegs = [
          ...bookedLegs,
          (booking: booking, flight: bookedFlight, seat: seat),
        ];
        final nextIndex = index + 1;
        final next = nextIndex < flights.length
            ? _buildSeatSelectionFor(
                context,
                flights,
                nextIndex,
                bookedLegs: updatedLegs,
              )
            : PaymentPage(
                bookedLegs: updatedLegs,
                onPaid: (paid) =>
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => PaymentSuccessPage(
                          payment: paid.payment,
                          bookedLegs: updatedLegs,
                        ),
                      ),
                    ),
              );
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
      },
    );
  }

  /// Uma reserva a pagar (hotel recém-criado ou reserva pendente de "Trips"):
  /// segue para a mesma revisão e pagamento do voo. As features entregam só o
  /// necessário (id, rótulo e valor); a ponte com a de reserva fica aqui, que
  /// já importa as duas.
  void _payItem(
    BuildContext context,
    ({int bookingId, String label, double price}) item,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentPage(
          items: [item],
          onPaid: (paid) =>
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PaymentSuccessPage(payment: paid.payment, items: [item]),
                ),
              ),
        ),
      ),
    );
  }

  /// Tocar um destino na aba Explore leva direto pros resultados reais
  /// daquela rota (origem+data já escolhidas na Home, via
  /// [searchOriginProvider] — Google Flights "Explore" e Skyscanner
  /// "Explore Everywhere" fazem o mesmo: nunca existe uma busca de "voos
  /// de uma região inteira", é sempre origem→destino→data). Reaproveita
  /// [_buildResultsPage], a mesma infra já usada pela jornada de reserva,
  /// em vez de duplicar lógica de navegação/busca.
  void _openExploreDestination(
    BuildContext context,
    Destination destination, {
    required bool isLoggedIn,
  }) {
    final current = ref.read(searchOriginProvider);
    if (current == null) {
      // Origem ainda não carregou (GET /destinations em voo) — não dá pra
      // fabricar uma (front burro): cai no fallback antigo de só
      // pré-preencher o destino e deixar o usuário buscar na Home.
      ref.read(prefillDestinationProvider.notifier).set(destination);
      setState(() => _tabIndex = 0);
      return;
    }

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => _buildResultsPage(
          context,
          FlightSearchQuery(
            origin: current.origin,
            destination: destination,
            date: current.date,
          ),
          const [],
          chosenFlights: const [],
          isLoggedIn: isLoggedIn,
        ),
      ),
    );
  }

  /// Tocar uma região no carrossel da Home abre a listagem real de
  /// destinos daquela região — mesma lista já carregada por
  /// `featuredDestinationsProvider` (sem fetch novo), só filtrada. Tocar
  /// um destino ali dentro reaproveita [_openExploreDestination] — mesmo
  /// comportamento de "resultados reais na hora" de qualquer outro card
  /// de destino do app.
  void _openRegionDestinations(
    BuildContext context,
    String region, {
    required bool isLoggedIn,
  }) {
    final destinations =
        ref.read(featuredDestinationsProvider).value ?? const [];
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => RegionDestinationsPage(
          region: region,
          destinations: destinations.where((d) => d.region == region).toList(),
          onSelectDestination: (destination) => _openExploreDestination(
            context,
            destination,
            isLoggedIn: isLoggedIn,
          ),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsPage(
          // todas as notificações de hoje falam de uma viagem: levam à aba Trips
          onOpen: (notification) {
            switch (notification.target) {
              case NotificationTarget.trips:
                navigator.popUntil((route) => route.isFirst);
                setState(() => _tabIndex = 2);
              case NotificationTarget.priceAlerts:
                navigator.popUntil((route) => route.isFirst);
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PriceAlertsPage(),
                  ),
                );
              case NotificationTarget.none:
                break;
            }
          },
          onOpenPreferences: () => navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => const NotificationPreferencesPage(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _homeActions(BuildContext context, {required bool isLoggedIn}) {
    return [
      if (isLoggedIn)
        NotificationBell(onPressed: () => _openNotifications(context)),
      IconButton(
        icon: const Icon(Icons.auto_awesome_outlined),
        tooltip: 'Perguntar à IA do DBook',
        onPressed: () => _openAiSuggestions(context, isLoggedIn: isLoggedIn),
      ),
      isLoggedIn
          ? IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => signOut(ref),
            )
          : IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Entrar',
              onPressed: () => pushAuthGate(context),
            ),
    ];
  }

  Widget _guestGate(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Scaffold(
      key: ValueKey('guest_gate_$title'),
      appBar: DbookAppBar(title: title),
      body: DbookStatusPlaceholder(
        icon: Icons.lock_outline,
        title: 'Entre para continuar',
        message: message,
        actionLabel: 'Entrar',
        onAction: () => pushAuthGate(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoggedIn = authState is AuthLoggedIn;
    // A origem das preferências da conta pré-preenche a busca da Home.
    if (isLoggedIn) {
      ref.listen(preferencesProvider, (_, next) {
        ref.read(homeAirportProvider.notifier).set(next.value?.homeAirport);
      });
    }
    // O aparelho se registra para *push* assim que a sessão começa (inclusive
    // quando ela é restaurada ao abrir o app).
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AuthLoggedIn && previous is! AuthLoggedIn) {
        ref.read(deviceRegistrarProvider).register();
      }
    });
    // Mesma lista já carregada pela Home/Explore — repassada pra
    // `MyBookingsPage` cruzar a foto do destino sem um fetch novo (as
    // duas features não podem importar uma à outra, então essa ponte só
    // pode acontecer aqui, que já importa as duas).
    final destinations =
        ref.watch(featuredDestinationsProvider).value ?? const [];

    final tabs = [
      FlightsHomePage(
        actions: _homeActions(context, isLoggedIn: isLoggedIn),
        onQueueLegs: (legs) => setState(() => _pendingLegs = legs),
        onBookFlight: (flight) => _selectFlight(
          context,
          flight,
          isLoggedIn: isLoggedIn,
          remainingLegs: _pendingLegs,
        ),
        liveAvailabilityBuilder: (flight) => DbookLiveAvailability(
          bookableId: flight.id,
          fallbackCapacity: flight.availableCapacity,
        ),
        onSelectRegion: (region) =>
            _openRegionDestinations(context, region, isLoggedIn: isLoggedIn),
        hotelPanelBuilder: (context, destinations) => StaySearchCard(
          destinations: destinations,
          pickDestination: showAirportPickerSheet,
        ),
        hotelResultsBuilder: (context) => StaySearchResults(
          isLoggedIn: isLoggedIn,
          onRequireLogin: () => pushAuthGate(context),
          onCheckout: (stay) => _payItem(context, stay),
        ),
        extrasBuilder: (context, destinations) => HomeStaysSection(
          destinations: destinations,
          isLoggedIn: isLoggedIn,
          onRequireLogin: () => pushAuthGate(context),
          onCheckout: (stay) => _payItem(context, stay),
          onSearchFlights: (destination) => _openExploreDestination(
            context,
            destination,
            isLoggedIn: isLoggedIn,
          ),
        ),
      ),
      ExplorePage(
        onSelectDestination: (destination) => _openExploreDestination(
          context,
          destination,
          isLoggedIn: isLoggedIn,
        ),
      ),
      isLoggedIn
          ? MyBookingsPage(
              destinations: destinations,
              onPay: (item) => _payItem(context, item),
              staysView: MyStaysList(onPay: (stay) => _payItem(context, stay)),
            )
          : _guestGate(
              context,
              title: 'Viagens',
              message: 'Faça login para ver suas reservas.',
            ),
      isLoggedIn
          ? const ProfilePage()
          : _guestGate(
              context,
              title: 'Perfil',
              message: 'Faça login para ver seu perfil.',
            ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Viagens',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.background,
    required this.title,
    required this.subtitle,
  });

  final Widget background;
  final String title;
  final String subtitle;
}

/// Onboarding de 3 slides — usa só componentes do design system.
/// [onFinished] dispara ao terminar o último slide (segue pro login).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  var _currentIndex = 0;

  static const _slides = [
    _OnboardingSlideData(
      background: Image(
        image: AssetImage('assets/images/onboarding/clouds_wing.jpg'),
        fit: BoxFit.cover,
      ),
      title: 'Descubra novos horizontes',
      subtitle:
          'Encontre e reserve os melhores voos para destinos incríveis '
          'em todo o mundo.',
    ),
    _OnboardingSlideData(
      background: Image(
        image: AssetImage('assets/images/onboarding/lakeside_village.jpg'),
        fit: BoxFit.cover,
      ),
      title: 'Os melhores preços, sempre',
      subtitle:
          'Compare centenas de companhias e encontre as melhores ofertas '
          'para a sua próxima aventura.',
    ),
    _OnboardingSlideData(
      background: Image(
        image: AssetImage('assets/images/onboarding/mountain_hiker.jpg'),
        fit: BoxFit.cover,
      ),
      title: 'Viaje do seu jeito',
      subtitle:
          'Opções flexíveis, reserva segura e uma experiência sem atrito.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex == _slides.length - 1) {
      widget.onFinished?.call();
      return;
    }
    _pageController.nextPage(
      duration: DbookMotion.base,
      curve: DbookMotion.standard,
    );
  }

  void _skip() => _pageController.jumpToPage(_slides.length - 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          final isLast = index == _slides.length - 1;

          return DbookOnboardingSlide(
            background: slide.background,
            title: slide.title,
            subtitle: slide.subtitle,
            pageCount: _slides.length,
            currentIndex: _currentIndex,
            primaryActionLabel: isLast ? 'Começar' : 'Avançar',
            onPrimaryAction: _next,
            onSkip: isLast ? null : _skip,
          );
        },
      ),
    );
  }
}
