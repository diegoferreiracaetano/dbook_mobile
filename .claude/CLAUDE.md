# DBook Mobile

Cliente **Flutter** (não é app Android nativo nem Compose — as pastas `android/`/`ios/` são só o runner) do backend DBook (`../dbook`, Kotlin/Spring). Monorepo com **melos + pub workspaces**. Hoje: onboarding, busca única de voo e hotel, vitrine de hotéis e pacotes (com foto), detalhe, reserva de assento e de quarto, pagamento com cupom, minhas viagens e estadias, reembolso, favoritos, alertas de preço, notificações, perfil completo (foto, preferências, senha, dispositivos), tempo real (disponibilidade) e sugestão por IA. Há também o **portal administrativo** (Flutter Web, `apps/dbook_admin`) para a equipe.

Idioma: docs (`README.md`, `CHECKLIST.md`, este arquivo), comentários/dartdoc e commits em **português**; identificadores em inglês. A interface do app de clientes é **toda em português** (decisão do M46). O app não tem l10n: os textos ficam no código da tela; o **portal** tem `dbook_admin_l10n` (ARB em português). Não volte a misturar idiomas numa tela.

> Regra de ouro: **não invente padrões**. Ache o irmão mais próximo (notifier, page, teste) e copie a forma dele. As skills em `.claude/skills/` têm exemplos reais.

## Princípios inegociáveis deste projeto

1. **Front burro.** O app só renderiza o que o backend manda. Nenhum dado de negócio inventado/hardcoded (lista de aeroportos, taxa, bagagem, "salvar cartão"…) e **nenhum botão que prometa algo sem função real por trás**. Se a referência visual mostra algo sem dado/endpoint real, exclua e avise — não fabrique. (Ex.: o Resumo do Pedido mostra só `flight.price` real, sem "Taxes & Fees".)
2. **Design system primeiro:** token → componente → feature. Cor/espaçamento/raio/tipografia vêm dos tokens/tema, nunca de número solto na feature.
3. **Sem estrutura paralela redundante:** reutilize dado já carregado (ex.: foto do destino vem de `featuredDestinationsProvider`, sem novo fetch).
4. **Features não importam features.** A composição entre elas acontece só em `apps/dbook_mobile/lib/main.dart` (via callbacks/parâmetros).

## Stack e versões (fonte: `pubspec.yaml` de cada pacote, `flutter --version`)

| Item | Versão / escolha |
|---|---|
| Flutter / Dart | 3.47.3 stable / 3.13.3 (`sdk: ^3.13.3`) |
| Monorepo | melos ^8.7.0 sobre pub workspaces (`flutter pub get` na raiz) |
| Estado / DI | flutter_riverpod ^3.4.3 — `Notifier`/`AsyncNotifier`/`FutureProvider` escritos à mão (sem `riverpod_generator`) |
| Modelos | freezed ^4.0.1 + freezed_annotation ^3.1.0; json_serializable ^6.11.1 **só** em `dbook_core_network` (DTOs) |
| HTTP | dio ^5.9.0 |
| Navegação | app de clientes: `Navigator`/`MaterialPageRoute` no root + `go_router` ^16.2.4 **só** dentro de `FlightsHomePage`; portal: `go_router` com URL por caminho em `apps/dbook_admin` |
| Storage | flutter_secure_storage ^11.1.1 (tokens), shared_preferences ^2.5.3 (onboarding/favoritos) |
| Tempo real | web_socket_channel ^3.0.1 (STOMP mínimo próprio) |
| Fontes/format | Roboto **empacotada** em `dbook_design_system/assets/fonts` (sem CDN: a CSP do portal bloqueia fonte remota), intl ^0.20.2 |
| Lint | flutter_lints ^6.0.0 / lints ^6.0.0 (`analysis_options.yaml` padrão, sem regras extras) |
| Testes | flutter_test / test, `fake_async` (timers), integration_test. **Sem lib de mock** (nada de mocktail/mockito) |

## Estrutura (grafo de dependência real)

```
apps/dbook_mobile/            composition root: main.dart (4 abas, Auth Gate, jornada de reserva), profile_page.dart, account/ (preferências, dispositivos, senha, foto), home_stays_section.dart (vitrine de hotéis e pacotes)
apps/dbook_admin/             portal administrativo (Flutter Web): go_router, redirecionamento por permissão, shell responsivo
packages/
  dbook_design_system/        tokens (DbookSpacing/Radius/...), DbookTheme, componentes Dbook* (inclui `DbookPhoto`, `DbookAirlineLogo`) — só Flutter (não conhece domínio)
    sample/  widgetbook/      apps de catálogo do design system
  dbook_domain/               Dart PURO: entidades (freezed), portas (abstract interface class XxxRepository), use_cases
  dbook_core_network/         Dio, DTOs (freezed+json), XxxRepositoryImpl, DbookNetworkException, wire_enums
  dbook_core_storage/         TokenStorage (secure storage)
  dbook_core_session/         dioProvider (token + refresh no 401), baseUrlProvider — compartilhado por toda feature
  dbook_feature_auth/  _flights/  _booking/  _realtime/  _ai/  _stays/  _notifications/   state/ (Notifier + freezed) + ui/ + barrel
  dbook_admin_data/           portal: modelos tolerantes (`JsonRead`), `Dio*Api`, `guarded()`
  dbook_admin_session/        portal: token em memória, renovação em voo único, `IdleGuard`, `DraftGuard`, `PermissionGate`
  dbook_admin_l10n/           portal: textos (ARB) e formatação
  dbook_feature_admin_{auth,team,customers,bookings,catalog,dashboard,governance}/   telas do portal por assunto
```

Setas: `domain` ← `core_network` ← `core_session` ← `feature_*` ← `app`; `design_system` é folha. Feature nova de negócio = pacote `dbook_feature_<x>` seguindo os irmãos; todo `src/` é privado e só o barrel `lib/dbook_feature_<x>.dart` exporta.

Estado real dos **use cases** de `dbook_domain`: existem e têm teste, mas as features **não** os usam — notifiers leem o repositório direto via provider (`ref.read(bookingRepositoryProvider).create(...)`). Em feature nova, siga o notifier vizinho; não introduza use case só por simetria.

## Convenções de código

- Arquivos `snake_case.dart`; classes `PascalCase`; componentes do design system prefixados `Dbook` (`DbookButton`); providers `xxxProvider`; notifiers `XxxNotifier`; estados `XxxState` com variantes `XxxIdle/XxxLoading/...` (freezed `sealed class`, `part 'xxx_state.freezed.dart'`).
- Porta = `abstract interface class XxxRepository` em `dbook_domain`; implementação `XxxRepositoryImpl(this._dio)` em `dbook_core_network`; provider do repositório vive no pacote da feature (`Provider<XxxRepository>((ref) => XxxRepositoryImpl(ref.watch(dioProvider)))`).
- DTO `XxxResponseDto`/`XxxRequestDto` (freezed + `fromJson`) com `toDomain()`; enum de fio (`UPPER_SNAKE`) traduzido em `wire_enums.dart`. O domínio não sabe de JSON.
- Página recebe **callbacks** para o que é de outra feature/decisão do app: `onBook`, `onBooked`, `onPaid`, `onSelectFlight`, ou um `Widget` (`liveAvailability`). Ela não navega para fora de si.
- Dartdoc em português explicando o **porquê**. Sem `TODO`.
- **Arquivos gerados** (`*.freezed.dart`, `*.g.dart`) são **versionados** (CI não roda codegen). Depois de mexer em entidade/DTO/state: `dart run build_runner build` dentro do pacote (a flag `--delete-conflicting-outputs` foi removida nesta versão do build_runner) e commite os gerados.
- Formatação: `dart format`. **Atenção:** hoje existem ~10 arquivos pré-existentes que o `dart format` da versão atual reformataria (visto em 2026-09-15; ex.: `date_strip_provider.dart`, `destination_repository_impl.dart`). Formate **só os arquivos que você tocou** (`dart format <arquivos>`) e não misture reformatação alheia num commit de feature.

## Estado, erros e assincronismo

- Estado de tela = `Notifier<XxxState>` sync com métodos `Future<void>`; lista remota = `AsyncNotifier`/`FutureProvider`. Estado "hub" que preserva contexto em erro (ver `SeatSelectionState.ready` com `bookingError`) em vez de perder a tela.
- Erro de rede: a camada `core_network` traduz `DioException` → `DbookNetworkException` **sealed** (`DbookValidation/Unauthorized/Forbidden/NotFound/Conflict/RateLimit/BadGateway/ServiceUnavailable/UnknownNetworkException`) via `mapDioException`, lendo `{"error": "..."}`. Notifier faz `on DbookNetworkException catch (error) { state = ...(error.message) }` — **a UI mostra `error.message`** (vem do backend), não texto próprio. Nada de `catch (_)` genérico.
- Ação pontual disparada por toque pode deixar a exceção subir ao chamador (ver `MyBookingsNotifier.cancel`); documente isso no dartdoc.
- Async: `async/await` com `Future`; **depois de `await` em widget, cheque `context.mounted`** antes de usar `context`. Efeito colateral de navegação a partir de estado usa `ref.listen` no `build` (ver `SeatSelectionPage`). Nada de `Future.delayed` como sincronização; timers só com teste em `fake_async`.
- Invalide o que ficou velho depois de mutação: `ref.invalidate(myBookingsNotifierProvider)`.

## UI

- Widgets: `StatelessWidget`/`ConsumerWidget`/`ConsumerStatefulWidget`. Espaçamento `DbookSpacing.{xs,sm,md,lg,xl,xxl,xxxl}`, raio `DbookRadius`, cor por `Theme.of(context).colorScheme` / `DbookStatusColors`. `Colors.white` literal só para texto **sobre imagem/gradiente** (padrão já usado em `DbookSuccessScreen`, hero do detalhe).
- Componente reutilizável entre features → `dbook_design_system` (+ export no barrel + teste + entrada no widgetbook quando cabível). Widget de uso único fica privado (`_Xxx`) no arquivo da tela.
- Tela com conteúdo que pode passar da altura: use rolagem (`SingleChildScrollView`) — já houve `RenderFlex overflow` real por isso.
- Imagem de rede (`Image.network`) precisa de fallback (gradiente) quando não há foto.
- Navegação: shell de 4 abas (`IndexedStack` + `NavigationBar`: Início, Explorar, Viagens, Perfil); a Home tem o seletor **Voos | Hotéis** no mesmo cartão de busca. Cuidado: a página raiz da Home mora num `GoRouter` que guarda o que construiu, por isso `FlightsHomePage` a reconstrói a cada mudança do pai (senão fica com o estado de visitante depois do login); login pelo Auth Gate (`pushAuthGate` em `main.dart`); jornada de reserva no `rootNavigator` com `MaterialPageRoute` orquestrada pelo `main.dart`; `go_router` só na aba Home.

## Estratégia de testes (detalhes na skill `flutter-testing`)

- Nome: `'given <contexto> when <ação> then <resultado>'` (inglês) em `test()`/`testWidgets()`.
- Layout: `test/{state,ui,data,use_cases,entities,dtos,repositories,support}` espelhando `lib/`.
- **Fakes escritos à mão** (`class _FakeXxxRepository implements XxxRepository`, com campos `captured*` e `error` opcional). Widget/notifier testados com `ProviderScope(overrides: [xxxRepositoryProvider.overrideWithValue(fake)])` / `ProviderContainer` + `addTearDown(container.dispose)`.
- `Image.network` em teste → `testWidgetsWithMockImages` (`dbook_feature_flights/test/support/mock_network_image.dart`).
- Widget test envolve em `MaterialApp(theme: DbookTheme.light, ...)`.
- `integration_test` existe (1 teste, precisa de device/emulador) — não é o caminho padrão.

## Comandos oficiais (rodar da raiz)

```bash
flutter pub get                    # resolve o workspace inteiro
melos run analyze                  # flutter analyze em todos os pacotes
melos run format                   # dart format --set-exit-if-changed . (CI) — ver aviso de arquivos pré-existentes acima
melos run test                     # flutter test nos pacotes Flutter
melos run test:dart                # dart test em dbook_domain e dbook_core_network
melos run coverage                 # flutter test --coverage
melos run coverage:dart            # dart test --coverage → lcov
./tool/combine_coverage.sh         # junta em coverage/lcov.info (CI exige ≥ 80%; último valor conhecido 80,68 % em 2026-10-10)

# um pacote só (mais rápido no dia a dia)
cd packages/dbook_feature_booking && flutter analyze && flutter test
cd packages/dbook_feature_booking && flutter test test/ui/payment_page_test.dart

# rodar o app (precisa do backend em :8080: `../dbook` → bootRun + docker compose up -d)
cd apps/dbook_mobile && flutter run
```

Cobertura combinada, número por linha: some `LF:`/`LH:` de `coverage/lcov.info` (é assim que os marcos do `CHECKLIST.md` reportam).

## Regras de qualidade (sempre valem)

- `flutter analyze` **sem nenhum issue** em todos os pacotes (não use `// ignore` sem motivo escrito).
- Cobertura combinada ≥ 80%; não exclua código para "subir o número".
- Sem dado de negócio hardcoded; sem token/segredo no repositório; sem log de token (`dbookNetworkLoggingProvider` só em `kDebugMode`).
- Sem dependência nova sem pedido explícito (nenhuma lib de mock, gerador de riverpod, get_it, bloc… — não fazem parte do projeto).
- Mudança de contrato com o backend (novo campo/endpoint): atualize DTO → entidade → mapper e o teste do DTO; o backend é o dono do contrato (ver `../dbook/.claude/CLAUDE.md`).
- Commits: português, um por marco (`Assento vira detalhe, revisão + pagamento no final (M18)`; o histórico antigo também usa `feat:`/`fix:` — mantenha o estilo recente). Não commitar/dar push sem pedido. Sem `Co-Authored-By` (preferência do dono).
- Marco fechado = `CHECKLIST.md` (seção `## Mn`, itens numerados, checklist de fechamento com cobertura) + `README.md` (Progresso).

## Definition of Done

Antes de dizer "pronto", confirme (ou diga por que não se aplica):

- [ ] Segue a estrutura de pacotes e o irmão mais próximo; nenhuma feature importando outra; `design_system` sem conhecer domínio.
- [ ] Front burro: nada inventado, nada de botão sem função real; dado reaproveitado em vez de novo fetch.
- [ ] Token/componente do design system usado (sem número/cor solta); componente compartilhado foi para o `dbook_design_system`.
- [ ] Erro tratado via `DbookNetworkException` com `error.message`; `context.mounted` após `await`.
- [ ] Testes criados/atualizados no padrão (`given/when/then`, fake à mão, `ProviderScope` overrides) cobrindo caminho feliz **e** erro.
- [ ] Codegen rodado e gerados commitados, se mexeu em freezed/DTO.
- [ ] `flutter analyze` limpo e testes do pacote + `melos run test`/`test:dart` verdes; `dart format` nos arquivos tocados.
- [ ] Mudança visual: **abri o app de verdade** (backend no ar, preview `dbook_mobile` do `.claude/launch.json`), olhei a tela, testei os estados — não basta teste verde. Flutter web é CanvasKit: use screenshot/coordenadas (`find`/`read_page` não enxergam o canvas) e, se o primeiro clique não pegar, repita.
- [ ] `CHECKLIST.md`/`README.md` atualizados quando fechou um marco.
- [ ] Relatório final lista **arquivos alterados** e **validações executadas** com o resultado real.
