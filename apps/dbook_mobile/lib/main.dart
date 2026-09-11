import 'dart:io';

import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Decide, a partir da sessão salva, qual fluxo mostrar: enquanto o
/// bootstrap roda (3.8) mostra um loading; depois, ou o usuário está logado
/// (`_HomePlaceholderPage`) ou passa pelo fluxo de onboarding/login/cadastro.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  var _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    // Riverpod não permite mudar o estado de um provider durante o build da
    // árvore de widgets — adia pro fim do primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).bootstrap().whenComplete(() {
        if (mounted) setState(() => _bootstrapped = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped) {
      return const Scaffold(body: DbookLoadingIndicator());
    }

    final state = ref.watch(authNotifierProvider);
    if (state is AuthLoggedIn) return const _HomePlaceholderPage();
    return const _UnauthenticatedFlow();
  }
}

/// Onboarding → Login ↔ Cadastro, com pilha de navegação de verdade
/// (voltar funciona) — rotas de feature de verdade chegam com `go_router`
/// em M4.
class _UnauthenticatedFlow extends StatelessWidget {
  const _UnauthenticatedFlow();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => switch (settings.name) {
            '/login' => LoginPage(
              onNavigateToRegister: () =>
                  Navigator.of(context).pushNamed('/register'),
            ),
            '/register' => RegisterPage(
              onNavigateToLogin: () => Navigator.of(context).pop(),
            ),
            _ => OnboardingPage(
              onFinished: () => Navigator.of(context).pushNamed('/login'),
            ),
          },
        );
      },
    );
  }
}

/// Placeholder da tela logada — nenhuma feature de verdade existe ainda
/// (chegam a partir do M4); só prova que a sessão (3.8/3.9) funciona.
class _HomePlaceholderPage extends ConsumerWidget {
  const _HomePlaceholderPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const DbookAppBar(title: 'DBook'),
      body: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Você está logado!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DbookSpacing.sm),
            Text(
              'As telas de busca e reserva chegam a partir do M4.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DbookSpacing.lg),
            DbookButton(
              label: 'Sair',
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            ),
          ],
        ),
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
