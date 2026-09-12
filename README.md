# DBook Mobile

Cliente Flutter do [DBook](../dbook) — consome a API de reservas de voos construída no projeto backend.

Monorepo gerenciado com [melos](https://melos.invertase.dev/), sobre o suporte nativo do Dart a [pub workspaces](https://dart.dev/tools/pub/workspaces).

## Estrutura

```
apps/
  dbook_mobile/                 # app Flutter de verdade
packages/
  dbook_design_system/          # tokens, tema e componentes compartilhados
    sample/                     # app de exemplo mostrando o design system
    widgetbook/                 # catálogo visual (Widgetbook)
  dbook_domain/                 # entidades, portas e casos de uso — Dart puro
  dbook_core_network/           # Dio, DTOs e implementação dos repositórios — Dart puro
  dbook_core_storage/           # storage seguro do par de tokens (flutter_secure_storage)
  dbook_core_session/           # Dio autenticado (token + refresh automático), compartilhado por toda feature
  dbook_feature_auth/           # telas de login/cadastro e sessão (Riverpod)
  dbook_feature_flights/        # busca, resultados e detalhe de voo (Riverpod + go_router)
  dbook_feature_booking/        # seleção de assento, confirmação e minhas reservas (Riverpod)
```

## Rodando localmente

Resolver o workspace inteiro a partir da raiz:

```bash
flutter pub get
```

Scripts do melos (rodam em todos os pacotes do workspace):

```bash
melos run analyze       # flutter analyze (todos os pacotes)
melos run format        # dart format --set-exit-if-changed . (todos os pacotes)
melos run test          # flutter test (pacotes Flutter com pasta test/)
melos run test:dart     # dart test (pacotes Dart puro com pasta test/ — dbook_domain, dbook_core_network)
melos run coverage      # flutter test --coverage (pacotes Flutter)
melos run coverage:dart # dart test --coverage + conversão pra lcov (pacotes Dart puro)
```

`dbook_domain`/`dbook_core_network` (entidades/DTOs) e `dbook_feature_auth`/`dbook_feature_flights`/`dbook_feature_booking` (estado, via `freezed` puro sem `json_serializable`) usam codegen; depois de mexer nesses arquivos, rodar `dart run build_runner build --delete-conflicting-outputs` dentro do pacote — os `.freezed.dart`/`.g.dart` ficam versionados (sem passo de codegen no CI).

Rodar cada app individualmente:

```bash
cd apps/dbook_mobile && flutter run
cd packages/dbook_design_system/sample && flutter run
cd packages/dbook_design_system/widgetbook && flutter run
```

Teste instrumentado (precisa de device/emulador real):

```bash
cd apps/dbook_mobile && flutter test integration_test/app_test.dart
```

## Progresso

Ver [CHECKLIST.md](CHECKLIST.md) para o detalhamento marco a marco.

- **M1 — Setup do monorepo + design system**: completo. `dbook_design_system` cobre tokens (cor/tipografia/espaçamento/raio/elevação/motion), tema claro/escuro, e todo o inventário de componentes extraído do UI kit de referência (ação, formulário, exibição de dados, navegação, feedback, overlays), com widget test em cada um. `apps/dbook_mobile` existe e consome o tema; a tela inicial é um onboarding de 3 slides (com fotos reais e ilustração no splash nativo) até o fluxo de auth (M2/M3) ser construído.
- **M2 — Domínio + rede**: completo. `dbook_domain` (entidades, portas, casos de uso) tem os campos batendo com o backend de verdade (survey do código-fonte, não suposição). `dbook_core_network` implementa as portas com Dio + DTOs (`freezed`/`json_serializable`) + mapeamento + exceptions por status HTTP. `dbook_core_storage` guarda o par de tokens no Keychain/EncryptedSharedPreferences.
- **M3 — Autenticação**: completo. `dbook_feature_auth` tem `LoginPage`/`RegisterPage` (montadas só com componentes do `dbook_design_system`), `AuthNotifier` (Riverpod) orquestrando loggedOut/loading/loggedIn/error e `PersistingAuthRepository` salvando o par de tokens a cada login/refresh. `apps/dbook_mobile` liga tudo: `_AppRoot` faz o bootstrap de sessão na abertura do app (token salvo → pula pra tela logada; senão → onboarding → login/cadastro).
- **M4 — Busca e listagem de voos**: completo. `dbook_core_session` (novo, extraído de `dbook_feature_auth`) centraliza o `Dio` autenticado — `DbookAuthInterceptor` anexa o access token em toda requisição e faz refresh automático no 401, com deduplicação de refresh concorrente, já que o refresh token do backend é de uso único; toda feature autenticada (auth e voos) compartilha essa mesma instância, o que é necessário pra deduplicação valer entre features, não só dentro de uma. `dbook_feature_flights` tem `FlightSearchPage` (seletor de aeroporto conhecido, já que o backend não expõe `/airports`), `FlightResultsPage` e `FlightDetailPage`, navegação via `go_router` embutido num `Router` próprio (sem precisar de um segundo `MaterialApp`). `apps/dbook_mobile` troca o placeholder de tela logada pela feature de voos de verdade, passando o botão de logout como ação da app bar.
- **M5 — Reserva**: completo. `dbook_feature_booking` tem `SeatSelectionPage` (mapa de assentos + confirmação antes de reservar de verdade), `BookingSuccessPage` e `MyBookingsPage`. O backend não expõe uma listagem de reservas (só criar/cancelar), então "minhas reservas" existe só em memória, populada pelas reservas feitas na sessão atual — não é um histórico persistente. `apps/dbook_mobile` liga o botão "Book This Flight" do detalhe do voo e o ícone de reservas na busca, do mesmo jeito que o M4 ligou o logout: via callback injetado, já que features não importam features entre si.
- **M6 em diante**: ainda não iniciado.
