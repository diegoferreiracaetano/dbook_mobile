import 'dart:io';

import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_feature_ai/dbook_feature_ai.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_realtime/dbook_feature_realtime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_page.dart';

/// Backend rodando localmente na máquina host: emulador Android enxerga o
/// host via `10.0.2.2`; todo o resto (iOS simulator, web, desktop) enxerga
/// via `localhost` normalmente.
String get _localApiBaseUrl {
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}

void main() {
  runApp(
    ProviderScope(
      overrides: [
        baseUrlProvider.overrideWithValue(_localApiBaseUrl),
        dbookNetworkLoggingProvider.overrideWithValue(kDebugMode),
      ],
      child: const DbookMobileApp(),
    ),
  );
}

class DbookMobileApp extends StatelessWidget {
  const DbookMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DBook',
      theme: DbookTheme.light,
      darkTheme: DbookTheme.dark,
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

  /// Trechos 2+ de uma busca Multi-city — populado quando a Home dispara
  /// [FlightsHomePage.onQueueLegs] (1º trecho segue pelo fluxo normal via
  /// `go_router` interno da Home). Consumido em [_bookFlight] pra saber
  /// se, depois de reservar o trecho atual, tem mais um pra encadear.
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
    pushAuthGate(context, onAuthenticated: (_) => const AiSuggestionPage());
  }

  /// Multi-city não é "1 trecho de verdade + resto decorativo": o backend
  /// não tem conceito de reserva multi-trecho (`POST /bookings` é sempre 1
  /// voo), então cada trecho vira uma compra real e independente,
  /// encadeada nesta mesma jornada — busca→detalhe→assento→confirmação,
  /// repetido pra cada trecho da lista. [remainingLegs] é o que falta
  /// depois do trecho atual; a tela de sucesso (`BookingSuccessPage`)
  /// oferece seguir pro próximo quando a lista não está vazia.
  static void _bookFlight(
    BuildContext context,
    Flight flight, {
    required bool isLoggedIn,
    List<FlightSearchQuery> remainingLegs = const [],
  }) {
    Widget buildSeatSelection(BuildContext _) {
      final nextLeg = remainingLegs.isEmpty ? null : remainingLegs.first;
      return SeatSelectionPage(
        flight: flight,
        nextLegLabel: nextLeg == null
            ? null
            : '${nextLeg.origin.label} → ${nextLeg.destination.label}',
        onNextLeg: nextLeg == null
            ? null
            : () => _searchNextLeg(
                context,
                nextLeg,
                remainingLegs.skip(1).toList(),
                isLoggedIn: isLoggedIn,
              ),
      );
    }

    if (isLoggedIn) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute<void>(builder: buildSeatSelection));
      return;
    }
    pushAuthGate(context, onAuthenticated: buildSeatSelection);
  }

  /// Busca o próximo trecho da fila — direto no root navigator (fora do
  /// `go_router` interno da `FlightsHomePage`, que só existe dentro da aba
  /// Home), reaproveitando `FlightResultsPage`/`FlightDetailPage` com
  /// `Navigator.push` comum, mesmo padrão que `pushAuthGate`/`_bookFlight`
  /// já usam.
  static void _searchNextLeg(
    BuildContext context,
    FlightSearchQuery query,
    List<FlightSearchQuery> remainingAfter, {
    required bool isLoggedIn,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => FlightResultsPage(
          query: query,
          onSelectFlight: (flight) => navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => FlightDetailPage(
                flight: flight,
                onBook: (selected) => _bookFlight(
                  context,
                  selected,
                  isLoggedIn: isLoggedIn,
                  remainingLegs: remainingAfter,
                ),
                liveAvailability: DbookLiveAvailability(
                  bookableId: flight.id,
                  fallbackCapacity: flight.availableCapacity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectExploreDestination(Destination destination) {
    ref.read(prefillDestinationProvider.notifier).set(destination);
    setState(() => _tabIndex = 0);
  }

  void _selectHomeRegion(String region) {
    ref.read(prefillRegionProvider.notifier).set(region);
    setState(() => _tabIndex = 1);
  }

  List<Widget> _homeActions(BuildContext context, {required bool isLoggedIn}) {
    return [
      IconButton(
        icon: const Icon(Icons.auto_awesome_outlined),
        tooltip: 'Ask DBook AI',
        onPressed: () => _openAiSuggestions(context, isLoggedIn: isLoggedIn),
      ),
      isLoggedIn
          ? IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
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

    final tabs = [
      FlightsHomePage(
        actions: _homeActions(context, isLoggedIn: isLoggedIn),
        onQueueLegs: (legs) => setState(() => _pendingLegs = legs),
        onBookFlight: (flight) => _bookFlight(
          context,
          flight,
          isLoggedIn: isLoggedIn,
          remainingLegs: _pendingLegs,
        ),
        liveAvailabilityBuilder: (flight) => DbookLiveAvailability(
          bookableId: flight.id,
          fallbackCapacity: flight.availableCapacity,
        ),
        onSelectRegion: _selectHomeRegion,
      ),
      ExplorePage(onSelectDestination: _selectExploreDestination),
      isLoggedIn
          ? const MyBookingsPage()
          : _guestGate(
              context,
              title: 'Trips',
              message: 'Faça login para ver suas reservas.',
            ),
      isLoggedIn
          ? const ProfilePage()
          : _guestGate(
              context,
              title: 'Profile',
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
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
      title: 'Discover New Horizons',
      subtitle:
          'Find and book the best flights to amazing destinations '
          'around the world.',
    ),
    _OnboardingSlideData(
      background: Image(
        image: AssetImage('assets/images/onboarding/lakeside_village.jpg'),
        fit: BoxFit.cover,
      ),
      title: 'Best Prices Everytime',
      subtitle:
          'Compare hundreds of airlines and get the best deals for '
          'your next adventure.',
    ),
    _OnboardingSlideData(
      background: Image(
        image: AssetImage('assets/images/onboarding/mountain_hiker.jpg'),
        fit: BoxFit.cover,
      ),
      title: 'Travel Your Way',
      subtitle: 'Flexible options, secure booking and a seamless experience.',
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
            primaryActionLabel: isLast ? 'Get Started' : 'Next',
            onPrimaryAction: _next,
            onSkip: isLast ? null : _skip,
          );
        },
      ),
    );
  }
}
