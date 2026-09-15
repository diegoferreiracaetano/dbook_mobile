# Checklist — DBook Mobile

Cliente Flutter do [DBook](../dbook) — consome a API de reservas de voos construída no projeto backend.

Checklist de fechamento (repetida ao final de cada marco, mesmo processo do backend):
1. Revisar os itens do marco — conferir que tudo foi implementado e testado.
2. Revisão de Clean Code (nomes, widgets pequenos e focados, duplicação, comentário só onde o "porquê" não é óbvio).
3. Revisão de arquitetura (camadas respeitadas — `dbook_domain` não importa Flutter; `dbook_feature_*` não importa outro `dbook_feature_*` diretamente, só via `dbook_domain`).
4. Revisão de componentização — **tudo é componentizado**: toda tela é composta só por componentes do `dbook_design_system` (botão, campo, card, item de lista etc.); zero widget de UI construído solto e uma única vez dentro de uma feature. Se um widget se repete (ou tem cara de que vai se repetir), ele sai da feature e vira componente do `dbook_design_system`.
5. Revisão de layout — a **montagem** da tela também segue padrão, não só os widgets isolados: espaçamento vem de `Spacing` (nunca um número solto tipo `SizedBox(height: 13)`), alinhamento/agrupamento repete os mesmos padrões de `Row`/`Column`/`Padding` já usados em outras telas, e qualquer arranjo de tela que se repita (ex.: cabeçalho + card + lista) vira um layout/slot reutilizável do `dbook_design_system` em vez de ser remontado à mão em cada feature.
6. Revisão de Material Design — os componentes do `dbook_design_system` são **temas/composições em cima de widgets Material 3** do próprio Flutter (`ElevatedButton`, `OutlinedButton`, `TextField`/`TextFormField`, `Card`, `NavigationBar`, `Chip`, `Switch`, etc.), nunca reconstruídos do zero com `Container`/`GestureDetector`. Isso vale acessibilidade, ripple, estados de foco e comportamento de plataforma de graça, e é o motivo de termos escolhido Material 3 lá no início do projeto.
7. `melos run analyze` + `dart format --set-exit-if-changed .` + `melos run test` passando limpos.
8. Testes adicionados pras camadas ainda não cobertas — unit nos casos de uso/repositórios, **widget test em todo componente do `dbook_design_system`** (não só no fechamento do marco, junto de cada componente conforme é criado) e widget test nas telas principais das features. Teste instrumentado (`integration_test`, roda em dispositivo/emulador de verdade) entra a partir do app funcionando de ponta a ponta (M3+).
9. README.md atualizado com o que foi feito no marco.
10. Cobertura de teste (`very_good_coverage` sobre o `lcov.info` combinado) acima do mínimo combinado.

## M1 — Setup do monorepo + design system ✅

Decisão: monorepo com [melos](https://melos.invertase.dev/) desde o início — mesma filosofia do M6 do DBook backend ("aprender o padrão certo agora, mesmo sem precisar em escala ainda"). Pacotes de verdade (não só pastas), cada um com seu próprio `pubspec.yaml`.

**O `dbook_design_system` é a base de tudo que vem depois — nenhuma feature deve ter cor, espaçamento, fonte ou raio "no olho" hardcoded no widget.** Tudo nasce de um token; o token vira tema; o tema alimenta os componentes; as features só consomem componentes prontos. Padronizar isso agora evita retrabalho em M3-M8.

- [x] 1.1 Instalar Flutter SDK (canal estável) + validar com `flutter doctor`
- [x] 1.2 Instalar melos + criar `melos.yaml` na raiz do monorepo
- [x] 1.3 Criar a estrutura `packages/` e `apps/dbook_mobile/`
- [x] 1.4 Criar o pacote `packages/dbook_design_system` (`pubspec.yaml` próprio)

**Design tokens (camada mais baixa, sem nenhuma lógica de UI):**
- [x] 1.5 Tokens de cor — paleta primitiva (`primary` `#0085FF` + variações) e paleta semântica (`onPrimary`, `surface`, `error`, `success`), light e dark
- [x] 1.6 Tokens de tipografia — escala Material 3 (display/headline/title/body/label) em Roboto, mapeada num `TextTheme`
- [x] 1.7 Tokens de espaçamento — spacing scale (4/8/12/16/24/32/48) como constantes nomeadas, não números soltos
- [x] 1.8 Tokens de raio de borda e elevação/sombra
- [x] 1.9 Tokens de motion — durações e curvas padrão de transição/animação

**Tema (junta os tokens em algo o Flutter consome):**
- [x] 1.10 `ThemeData` completo (light + dark) montado só a partir dos tokens acima — nenhuma cor/fonte solta fora do tema

**Componentes — duas regras: (1) se aparece em mais de uma tela (ou tem cara de que vai aparecer), é componente do `dbook_design_system`, nunca widget solto numa feature — consomem só o tema, nunca um token bruto direto na feature; (2) cada componente é um tema/composição em cima do widget Material 3 equivalente do Flutter, não uma reconstrução do zero. Lista extraída revisando as 17 telas do [UI kit](https://claude.ai/code/artifact/a2793fd6-4385-4100-a319-c6d70e70c3bf) — cobre tudo que já apareceu em algum desenho, agrupado por função:**

*Ação:*
- [x] 1.11 Botão (primary/secondary/text; estados default/disabled/loading)
- [x] 1.12 Botão de ícone circular e botão de destaque circular (ex.: sino, voltar, trocar origem/destino) — `IconButton`/`IconButton.filled()` nativos já saem corretos via `ColorScheme`, sem componente extra
- [x] 1.13 Segmented control / toggle (ex.: ida × ida-e-volta) — `SegmentedButton` temático

*Formulário:*
- [x] 1.14 Campo de texto outlined (estados default/foco/erro/disabled; ícone à esquerda; ícone à direita ex. mostrar senha) — `InputDecorationTheme`, `TextField`/`TextFormField` nativos
- [x] 1.15 Campo de busca (ícone + placeholder) e seletor de data / intervalo de datas — `DbookSearchField` e `datePickerTheme` (`showDateRangePicker` nativo)
- [x] 1.16 Legenda de seleção (swatch + rótulo, ex. livre/selecionado/ocupado no mapa de assento) — `DbookLegendItem`
- [x] 1.16b Checkbox (ex. aceite de termos no Cadastro, lista de companhias no filtro) — `CheckboxListTile`/`Checkbox` nativos já saem corretos via `checkboxTheme`, sem componente extra (mesmo padrão do 1.12)
- [x] 1.16c Campo de seleção / dropdown (ex. nacionalidade, gênero no Passageiro) — `DropdownButtonFormField` nativo já sai correto via `inputDecorationTheme`, sem componente extra
- [x] 1.16d Slider de faixa de valores (ex. price range no filtro de busca) — `RangeSlider` nativo já sai correto via `sliderTheme`, sem componente extra
- [x] 1.16e Botão de login social (Google/Apple/Facebook, ícone circular de marca) — `DbookSocialLoginButton` + `DbookSocialLoginRow` (ícone é placeholder até ligar login social de verdade em M2)

*Exibição de dados:*
- [x] 1.17 Card base (elevado/tonal) e item de lista genérico (ícone/imagem + título + subtítulo + seta) — fundação dos itens abaixo — `cardTheme`/`listTileTheme`, `Card`/`ListTile` nativos
- [x] 1.18 Avatar (foto/inicial, tamanhos), Chip neutro, Badge de status semântico (confirmada/pendente/cancelada, cor por estado) — `DbookAvatar`, `chipTheme`, `DbookStatusBadge`
- [x] 1.19 Card de destino (foto + degradê + título/subtítulo sobrepostos) e linha de resultado de voo (horário, duração, preço, estado selecionado) — `DbookDestinationCard`, `DbookFlightResultTile`
- [x] 1.19b Enriquecer `DbookFlightResultTile`: logo/ícone da companhia, número do voo, badge "sem escalas"/paradas e seta — versão atual só tem horário/duração/preço
- [x] 1.20 Célula de mapa de assento (3 estados) e bloco de código QR/barcode — `DbookSeatCell`, `DbookQrPlaceholder`
- [x] 1.20b Cartão de resumo de busca (origem ⇄ destino, datas, passageiros) — usado cheio na Home/Busca e compacto no topo de Resultados — `DbookTripSummaryCard`
- [x] 1.21 Estilo de preço em destaque (tipografia grande, reusada em Detalhe do voo / Revisar reserva / Bilhete) — `DbookPriceDisplay`
- [x] 1.21b Faixa horizontal de data+preço (seletor de datas com tarifa do dia, dia selecionado em destaque) — usada no topo de Resultados — `DbookFareDateStrip`
- [x] 1.21c Badge numérico sobre ícone (ex. contador de notificação "3" no Drawer/Menu) — `Badge` (M3) temático, diferente do `DbookStatusBadge` (que é pill de texto, não contador) — `DbookNotificationBadge` + `badgeTheme`
- [x] 1.21d Item de extra/serviço com preço (ícone + título + descrição + preço à direita, ex. "Seat Selection $15" em Passageiro & Extras) — `DbookPricedListItem`
- [x] 1.21e Linha de resumo rótulo↔valor (ex. "Order Summary" no Pagamento, resumo da reserva) — lista de pares label/valor terminando num total em destaque — `DbookSummaryRow`

*Navegação e estrutura:*
- [x] 1.22 App bar (variantes: cor sólida, transparente sobre imagem, com botão voltar, com subtítulo) — `DbookAppBar` + `appBarTheme`
- [x] 1.23 Barra de navegação inferior (com indicador "pill" no item ativo) e Drawer de navegação — `NavigationBar`/`Drawer` nativos via `navigationBarTheme`/`drawerTheme`, sem componente extra
- [x] 1.24 Rótulo de seção (texto pequeno + ícone, ex. "SUGESTÕES PRA VOCÊ") e Divisor (sólido e tracejado) — `DbookSectionLabel`, `Divider` via `dividerTheme`, `DbookDashedDivider`
- [x] 1.24b TabBar temático (ex. "Fly/Sleep/Eat" na Home, "Upcoming/Past" em Minhas Viagens) — indicador sublinhado, diferente do `SegmentedButton` (1.13, que é toggle tipo pill) — `TabBar` nativo via `tabBarTheme`

*Feedback:*
- [x] 1.25 Indicador de carregamento, estado vazio, estado de erro (padrão reusado em toda tela que busca dado) — `DbookLoadingIndicator`, `DbookStatusPlaceholder`
- [x] 1.26 Estado de sucesso inline (ícone grande em círculo) e faixa de status inline (ex. "Disponibilidade em tempo real") — `DbookStatusPlaceholder` (círculo maior), `DbookInlineStatusBanner`
- [x] 1.26b Tela de sucesso completa (fundo cheio + ícone com sparkles decorativos + cartão de referência com copiar + dois botões + ilustração de skyline) — versão rica pro fluxo de Confirmação de reserva, `DbookSuccessScreen`

*Overlays:*
- [x] 1.27 Bottom sheet e dialog de confirmação — `showModalBottomSheet` via `bottomSheetTheme`, `showDbookConfirmationDialog` via `dialogTheme`
- [x] 1.28 Indicador de página / dots (usado no onboarding) — `DbookPageIndicator`
- [x] 1.28b Slide de onboarding completo (foto cheia + degradê + título/subtítulo + dots + Skip/Next) — composição usando 1.28 — `DbookOnboardingSlide`

**Documentação viva dos componentes:**
- [x] 1.29a App de exemplo (`packages/dbook_design_system/sample/`) mostrando tema (claro/escuro) e todos os componentes construídos até agora
- [x] 1.29b Catálogo visual (ex.: [Widgetbook](https://pub.dev/packages/widgetbook)) mostrando cada componente/estado isolado, pra QA visual sem precisar rodar o app inteiro — `packages/dbook_design_system/widgetbook/` (26 componentes, 28 casos de uso), tema claro/escuro via `MaterialThemeAddon`

**App raiz + CI:**
- [x] 1.30 Criar o app Flutter raiz em `apps/dbook_mobile/`, consumindo o tema do `dbook_design_system` via dependência `path:` — home é um onboarding de 3 slides com `DbookOnboardingSlide` (não há feature real ainda, M2+)
- [x] 1.31 Configurar `integration_test` no app raiz (smoke test instrumentado: abre o app, renderiza a primeira tela — a partir daqui todo fluxo de feature ganha teste instrumentado além do widget test) — `integration_test/app_test.dart` (roda em device/emulador de verdade, não neste ambiente)
- [x] 1.32 CI (GitHub Actions): `melos bootstrap` + `melos run analyze` + `dart format --set-exit-if-changed .` — `.github/workflows/ci.yml`
- [x] 1.33 CI: adicionar `melos run test` ao workflow — mesmo `ci.yml`

**Checklist de fechamento do M1:**
- [x] Itens 1.1-1.33 revisados — todos `[x]`
- [x] Nenhum valor de cor/espaçamento/fonte hardcoded fora do `dbook_design_system` (grep rápido por hex codes soltos nas features) — único achado em `apps/dbook_mobile/lib/main.dart` são as 6 cores do gradiente decorativo do onboarding (arte de fundo one-off, mesmo padrão já usado no scrim do `DbookDestinationCard` e nos cards do `sample`), não um token semântico reinventado
- [x] Clean Code — `apps/dbook_mobile/lib/main.dart` tem 133 linhas, widgets pequenos e focados (`DbookMobileApp`, `OnboardingPage`, `_OnboardingSlideData`), zero duplicação
- [x] Arquitetura — `dbook_mobile` só importa `dbook_design_system` e `flutter_riverpod`; `dbook_domain`/camadas de feature ainda não existem (chegam em M2), então não há violação de camada possível ainda
- [x] Componentização — a única tela do app (`OnboardingPage`) é montada 100% com `DbookOnboardingSlide`; nenhum widget de UI construído solto na feature
- [x] Layout — espaçamento/composição vêm de dentro do `DbookOnboardingSlide`; o app não redeclara `SizedBox`/`EdgeInsets` com número solto
- [x] Material Design — `Scaffold` + `PageView` nativos, tema aplicado via `DbookTheme.light`/`.dark`
- [x] `analyze` + `format` + `test` limpos — 4 pacotes (`dbook_design_system`, `sample`, `widgetbook`, `dbook_mobile`) validados
- [x] Testes das camadas ainda sem cobertura — não aplicável ainda (sem `dbook_domain`/`dbook_core_*`, chegam em M2); `dbook_mobile` tem 2 widget tests + `integration_test/app_test.dart` pronto pra CI
- [x] README atualizado — [README.md](README.md) criado (estrutura, como rodar, progresso por marco)
- [x] Cobertura mínima — `melos run coverage` + `tool/combine_coverage.sh` + gate `VeryGoodOpenSource/very_good_coverage` (mínimo 80%) no CI; localmente: **93.70%** (774/826 linhas)

## M2 — Domínio + rede ✅

Decisão: `dbook_domain` é Dart puro, zero dependência de Flutter/Riverpod — mesmo princípio de Clean Architecture do backend. Serialização via `freezed` + `json_serializable` (padrão de mercado pra imutabilidade + codegen de JSON em Dart).

- [x] 2.1 Criar o pacote `packages/dbook_domain` (Dart puro, sem dependência de Flutter) — `dart create --template=package`, sem `flutter` no pubspec
- [x] 2.2 dbook_domain: entidade `Flight` — campos batem com `FlightResponse` do backend (origem/destino são código IATA, não `Airport` aninhado — é isso que `GET /flights/search` de fato devolve)
- [x] 2.3 dbook_domain: entidade `Airport`
- [x] 2.4 dbook_domain: entidade `Booking` (+ enum de status) — `BookingStatus` (pending/confirmed/cancelled)
- [x] 2.5 dbook_domain: entidade `User` — sem `passwordHash`, que nunca sai do backend
- [x] 2.6 dbook_domain: entidade `AiSuggestion`
- [x] 2.7 dbook_domain: portas (interfaces) — `FlightRepository`, `BookingRepository`, `AuthRepository`, `AiSuggestionRepository`
- [x] 2.8 dbook_domain: casos de uso — `SearchFlightsUseCase`, `GetSeatsUseCase`, `RegisterBookingUseCase`, `CancelBookingUseCase`, `LoginUseCase`, `RegisterUseCase`, `RefreshSessionUseCase`, `SuggestFlightsUseCase`, todos com teste usando fake de repositório escrito à mão (interfaces pequenas, sem lib de mock)
- [x] 2.9 Criar o pacote `packages/dbook_core_network`, configurar Dio (base URL, timeouts, logging em debug) — `DbookDioClient.create()`; interceptor de auth (anexar token, refresh no 401) fica pro M3, junto da sessão
- [x] 2.10 dbook_core_network: DTOs com `freezed` + `json_serializable` (build_runner) — 12 DTOs cobrindo auth, busca de voo, assentos, reserva e sugestão de IA, campo a campo batendo com o survey do backend real
- [x] 2.11 dbook_core_network: mapeamento DTO → entidade de domínio — `toDomain()` em cada DTO; enums do domínio continuam Dart puro (sem `json_serializable`), tradução via `wire_enums.dart`; também vieram as implementações reais dos 4 repositórios (`*RepositoryImpl`), fechando as portas do `dbook_domain`
- [x] 2.12 dbook_core_network: exceptions de rede mapeadas a partir do status HTTP da API — `DbookNetworkException` (400/401/403/404/409/429/502/503 + fallback), lendo `{"error": "..."}` do corpo quando presente
- [x] 2.13 Criar o pacote `packages/dbook_core_storage` (`flutter_secure_storage`), wrapper pra salvar/ler o par de tokens — `TokenStorage` (porta) + `SecureTokenStorage` (Keychain/EncryptedSharedPreferences via `flutter_secure_storage`); testado com `FlutterSecureStorage.setMockInitialValues` (suporte de teste oficial do próprio pacote)

**Checklist de fechamento do M2:**
- [x] Itens 2.1-2.13 revisados — todos `[x]`
- [x] Clean Code — classes pequenas e focadas (cada caso de uso faz uma coisa só), sem duplicação; comentários só onde o "porquê" não é óbvio (ex.: por que `Flight` usa código IATA em vez de `Airport` aninhado, por que `bookableId` nulo vira `StateError` em vez de default silencioso)
- [x] Arquitetura — `dbook_domain` sem nenhuma dependência externa além de `freezed_annotation`; `dbook_core_network` e `dbook_core_storage` dependem só de `dbook_domain` (nunca o contrário); nenhuma feature ainda existe pra checar violação de camada entre features (M3+)
- [x] Componentização — não se aplica neste marco (sem tela nova; M2 é domínio/rede/storage)
- [x] Layout — não se aplica neste marco
- [x] Material Design — não se aplica neste marco
- [x] `analyze` + `format` + `test` limpos — 7 pacotes (`dbook_design_system` + 3 apps/exemplos + `dbook_domain` + `dbook_core_network` + `dbook_core_storage`), `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — entidades, portas (via fake), casos de uso, DTOs, mapeamento, exceptions e repositórios (`dbook_domain`/`dbook_core_network`) e o wrapper de storage (`dbook_core_storage`, mock oficial do `flutter_secure_storage`) todos testados
- [x] README atualizado — [README.md](README.md) com a estrutura nova, scripts de cobertura Dart puro, e progresso do M2
- [x] Cobertura mínima — `melos run coverage` + `melos run coverage:dart` (excluindo `.freezed.dart`/`.g.dart` gerados) + `tool/combine_coverage.sh`, gate de 80% no CI; localmente: **83.43%** (1188/1424 linhas)

## M3 — Autenticação ✅

- [x] 3.1 Criar o pacote `packages/dbook_feature_auth`
- [x] 3.2 Tela de registro (formulário + validação) — `RegisterPage`
- [x] 3.3 Tela de login (formulário + validação) — `LoginPage`
- [x] 3.4 Riverpod: `AuthNotifier` (estados loggedOut/loading/loggedIn/error)
- [x] 3.5 Implementação real do `AuthRepository` (usa `dbook_core_network`, salva tokens no `dbook_core_storage`) — `PersistingAuthRepository` decora o `AuthRepositoryImpl` de rede
- [x] 3.6 Interceptor Dio: anexa o access token em toda requisição autenticada — `DbookAuthInterceptor.onRequest`
- [x] 3.7 Interceptor Dio: detecta 401, faz refresh automático, repete a requisição original — `DbookAuthInterceptor.onError`, com deduplicação de refresh concorrente (`_refreshing`)
- [x] 3.8 Bootstrap de sessão: app abre e checa token válido salvo, pula direto pra tela logada — `_AppRoot` chama `AuthNotifier.bootstrap()` no `initState` (adiado pro fim do primeiro frame, Riverpod não deixa mudar provider durante o build) e mostra loading até resolver
- [x] 3.9 Logout: limpa o secure storage, volta ao estado loggedOut — botão "Sair" no placeholder de tela logada chama `AuthNotifier.logout()`

**Checklist de fechamento do M3:**
- [x] Itens 3.1-3.9 revisados — todos `[x]`
- [x] Clean Code — `AuthNotifier`/`PersistingAuthRepository`/`DbookAuthInterceptor` cada um faz uma coisa só; comentário só onde o "porquê" não é óbvio (ex.: por que o Dio de auth não tem o interceptor — evitar loop de refresh; por que o refresh é deduplicado — token de uso único no backend; por que a chamada de bootstrap é adiada pro fim do primeiro frame — Riverpod não deixa mudar provider durante o build)
- [x] Arquitetura — `dbook_feature_auth` depende só de `dbook_domain`/`dbook_core_network`/`dbook_core_storage`/`dbook_design_system` (nenhuma outra feature ainda existe pra violar); `apps/dbook_mobile` só compõe (nenhuma lógica de auth mora no app, só o `_AppRoot` decidindo qual tela mostrar a partir do estado)
- [x] Componentização — `LoginPage`/`RegisterPage`/o placeholder de tela logada usam só `DbookAppBar`/`TextFormField`/`DbookInlineStatusBanner`/`DbookButton`/`DbookSocialLoginRow`/`CheckboxListTile`/`DbookLoadingIndicator` do `dbook_design_system` ou widgets Material nativos já temáticos; zero widget de UI construído solto
- [x] Layout — espaçamento vem de `DbookSpacing`, nenhum número solto; título do `RegisterPage` (`Join Dbook`) foi ajustado pra não colidir com o texto do botão (`Create Account`), evitando ambiguidade tanto pro usuário quanto pros finders de teste
- [x] Material Design — `TextFormField`/`CheckboxListTile`/`Scaffold` nativos via tema, nada reconstruído do zero
- [x] `analyze` + `format` + `test` limpos — 8 pacotes, `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — `PersistingAuthRepository`, `DbookAuthInterceptor` (anexa token, refresh+retry, dedup de refresh concorrente), `AuthNotifier` (7 casos, todas as transições de estado), `LoginPage`/`RegisterPage` (validação, submit feliz, erro do backend) e o fluxo completo em `apps/dbook_mobile` (onboarding → login, via `_AppRoot`)
- [x] README atualizado — [README.md](README.md) com `dbook_feature_auth` na estrutura e progresso do M3
- [x] Cobertura mínima — combinado (`melos run coverage` + `coverage:dart` + `tool/combine_coverage.sh`): **82.66%** (1378/1667 linhas); `dbook_feature_auth` sozinho: 83.42%

## M4 — Busca e listagem de voos ✅

Decisão: `dioProvider`/`DbookAuthInterceptor` saíram de `dbook_feature_auth` pro novo pacote `packages/dbook_core_session` — a feature de voos precisa do mesmo Dio autenticado, e duas instâncias de interceptor deduplicando refresh cada uma sozinha reabriria a race condition do refresh token de uso único (M3). Decisão: como o backend não expõe `/airports`, a busca usa uma lista fixa de aeroportos (`knownAirports`, espelhando o seed de dev) num seletor em vez de um campo de texto pra código IATA.

- [x] 4.1 Criar o pacote `packages/dbook_feature_flights`
- [x] 4.2 Tela de busca (origem/destino/data) — `FlightSearchPage`, com `DbookTripSummaryCard` (cheio) e seletor de aeroporto em bottom sheet
- [x] 4.3 Implementação real do `FlightRepository` — já existia desde o M2 (`FlightRepositoryImpl`); só faltava o provider ligando ao Dio autenticado
- [x] 4.4 Riverpod: `FlightSearchNotifier` (estados idle/loading/success/error)
- [x] 4.5 Lista de resultados (item de voo usando o `dbook_design_system`) — `FlightResultsPage` com `DbookFlightResultTile`, `DbookStatusPlaceholder` pros estados vazio/erro (com retry) e `DbookLoadingIndicator` pro loading
- [x] 4.6 Tela de detalhe do voo (navegação via `go_router`) — `FlightDetailPage`; `FlightsHomePage` embute um `GoRouter` próprio (`Router.withConfig`, sem precisar de um segundo `MaterialApp`) pras 3 rotas busca→resultados→detalhe

**Checklist de fechamento do M4:**
- [x] Itens 4.1-4.6 revisados — todos `[x]`
- [x] Clean Code — `FlightSearchNotifier` só orquestra estado, formatação (data/preço/duração) isolada em funções top-level reusadas entre telas, comentário só onde o "porquê" não é óbvio (ex.: por que `stopsLabel` mostra a classe da cabine em vez de "paradas", por que não existe seletor de passageiros de verdade)
- [x] Arquitetura — `dbook_feature_flights` depende só de `dbook_domain`/`dbook_core_network`/`dbook_core_session`/`dbook_design_system` (nunca de `dbook_feature_auth`); a tela de voos recebe o botão de logout já pronto via parâmetro (`logoutAction`) em vez de importar a feature de auth
- [x] Componentização — todas as 3 telas usam só `DbookAppBar`/`DbookTripSummaryCard`/`DbookButton`/`DbookFlightResultTile`/`DbookStatusPlaceholder`/`DbookLoadingIndicator`/`DbookSummaryRow`/`DbookPriceDisplay` do `dbook_design_system`, ou widgets Material nativos já temáticos (`Chip`, `ListTile`, `showDatePicker`); zero widget de UI construído solto
- [x] Layout — espaçamento vem de `DbookSpacing`; gap real encontrado no `DbookTripSummaryCard` (um único `onTapRoute` não dava pra diferenciar toque em origem/destino) foi corrigido no próprio design system (`onTapDestination` novo), não contornado na feature
- [x] Material Design — `Chip`/`ListTile`/`showModalBottomSheet`/`showDatePicker` nativos via tema, nada reconstruído do zero
- [x] `analyze` + `format` + `test` limpos — 10 pacotes, `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — `FlightSearchNotifier` (idle/success/error), `FlightSearchPage` (seleção padrão, seletor de aeroporto, ações da app bar), `FlightResultsPage` (sucesso/vazio/erro+retry/seleção), `FlightDetailPage`, `DbookAuthInterceptor` (movido, reteste) e o novo callback `onTapDestination` do `DbookTripSummaryCard`
- [x] README atualizado — [README.md](README.md) com `dbook_core_session`/`dbook_feature_flights` na estrutura e progresso do M4
- [x] Cobertura mínima — combinado: **83.34%** (1531/1837 linhas); `dbook_feature_flights` sozinho: 85.31%

## M5 — Reserva ✅

Decisão: o backend não expõe um "GET /bookings" (só criar e cancelar) — não tem como listar as reservas do usuário depois que o app fecha. "Minhas reservas" (5.5) mostra as reservas feitas **nesta sessão** (`MyBookingsNotifier`, em memória, enriquecidas com o `Flight`/`Seat` já em mãos no momento da reserva), não um histórico persistente. Mesmo espírito da decisão dos aeroportos no M4: entregar algo real e honesto com o que a API de fato oferece, documentado, em vez de inventar um endpoint que não existe.

- [x] 5.1 Criar o pacote `packages/dbook_feature_booking`
- [x] 5.2 Implementação real do `BookingRepository` — já existia desde o M2 (`BookingRepositoryImpl`); só faltava o provider ligando ao Dio autenticado
- [x] 5.3 Ação de reservar a partir da tela de detalhe (botão + confirmação) — `FlightDetailPage.onBook` (novo, opcional) abre `SeatSelectionPage`; `showDbookConfirmationDialog` antes de criar a reserva de verdade
- [x] 5.4 Riverpod: `BookingNotifier` — `SeatSelectionNotifier` (idle/loadingSeats/seatsError/ready com seleção+erro de reserva embutidos/booked) + `MyBookingsNotifier` (lista da sessão)
- [x] 5.5 Tela "minhas reservas" (lista com status PENDING/CONFIRMED/CANCELLED) — `MyBookingsPage`, com a ressalva de escopo acima
- [x] 5.6 Ação de cancelar reserva — botão no `MyBookingsPage` (só quando `PENDING`, mesma regra do backend), com confirmação
- [x] 5.7 Tratamento de erro específico: 409 (sem disponibilidade), 403 (não é dono), 404 — `DbookNetworkException.message` já carrega a mensagem do backend pra cada um desses status (mapeados desde o M2); a reserva mostra inline sem perder o mapa de assentos, o cancelamento mostra num snackbar

**Checklist de fechamento do M5:**
- [x] Itens 5.1-5.7 revisados — todos `[x]`
- [x] Clean Code — `SeatSelectionNotifier`/`MyBookingsNotifier` cada um cuida de uma responsabilidade; comentário só onde o "porquê" não é óbvio (ex.: por que `BookingRecord` só existe em memória, por que o estado `ready` guarda o erro de reserva em vez de ter um estado `error` separado — perder o mapa de assentos numa falha de reserva seria pior UX)
- [x] Arquitetura — `dbook_feature_booking` depende só de `dbook_domain`/`dbook_core_network`/`dbook_core_session`/`dbook_design_system`; monta seu próprio `flightRepositoryProvider` interno (não exportado) em vez de importar o de `dbook_feature_flights`, já que features não importam features; a ligação busca↔reserva (botão "Book This Flight", ícone "My Bookings") é feita pelo app via callbacks injetados, mesmo padrão do logout no M4
- [x] Componentização — `SeatSelectionPage`/`BookingSuccessPage`/`MyBookingsPage` usam só `DbookSeatCell`/`DbookLegendItem`/`showDbookConfirmationDialog`/`DbookSuccessScreen`/`DbookStatusBadge`/`DbookInlineStatusBanner`/`DbookStatusPlaceholder` do `dbook_design_system`; zero widget de UI construído solto
- [x] Layout — espaçamento vem de `DbookSpacing`, grid de assentos via `GridView`/`SliverGridDelegateWithFixedCrossAxisCount` (padrão nativo, não remontado à mão)
- [x] Material Design — `GridView`/`Card`/`showModalBottomSheet`/`AlertDialog` (via `showDbookConfirmationDialog`) nativos via tema
- [x] `analyze` + `format` + `test` limpos — 11 pacotes, `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — `SeatSelectionNotifier` (carregar assentos, selecionar, confirmar com sucesso/erro 409), `MyBookingsNotifier` (adicionar, cancelar com sucesso/erro 403), `SeatSelectionPage`, `MyBookingsPage` (vazio, pendente com cancelar, confirmada sem cancelar, cancelamento com sucesso/erro) e o novo `FlightDetailPage.onBook`
- [x] README atualizado — [README.md](README.md) com `dbook_feature_booking` na estrutura e progresso do M5
- [x] Cobertura mínima — combinado: **84.27%** (1709/2028 linhas); `dbook_feature_booking` sozinho: 93.99%

## M6 — Tempo real ✅

Decisão: mesmo padrão do M5 do backend — WebSocket/STOMP, não polling. Client em Dart via `web_socket_channel` (STOMP é só um protocolo de frame em cima de WebSocket puro, não precisa de biblioteca STOMP-específica pra um caso de uso tão focado). Contrato verificado lendo o backend de verdade (não suposto): endpoint `/ws` sem SockJS, autenticação via header STOMP nativo `Authorization: Bearer <token>` no CONNECT (não dá pra mandar header HTTP custom no handshake do WebSocket), tópico `/topic/bookables/{id}/availability`, payload `{"bookableId", "availableCapacity"}`, sem prefixo `/app` — o cliente só assina, nunca manda SEND. Broker em memória sem fila/replay: se a conexão cair no meio de uma atualização, ela é só perdida (o backend documenta isso), então o cliente guarda o último valor conhecido em vez de tentar garantir entrega.

- [x] 6.1 Criar o pacote `packages/dbook_feature_realtime`
- [x] 6.2 Cliente STOMP mínimo sobre `web_socket_channel` (frame CONNECT com header Authorization) — `StompFrame` (parse/serialize) + `StompAvailabilityClient`
- [x] 6.3 Assinatura por tópico (`/topic/bookables/{id}/availability`)
- [x] 6.4 Parse do frame MESSAGE recebido
- [x] 6.5 Integração na tela de detalhe do voo: assina ao entrar, cancela a assinatura ao sair, atualiza disponibilidade ao vivo — `DbookLiveAvailability` (widget), injetado em `FlightDetailPage` via `liveAvailability` (mesmo padrão de `onBook`/`logoutAction`, já que a feature de voos não conhece a de tempo real)
- [x] 6.6 Tratamento de desconexão/reconexão do WebSocket — backoff (2s, 4s, ..., até 10s) guardando o último valor conhecido durante a reconexão, sem perder o número exibido

**Checklist de fechamento do M6:**
- [x] Itens 6.1-6.6 revisados — todos `[x]`
- [x] Clean Code — `StompFrame` (parse/serialize), `StompAvailabilityClient` (conexão/reconexão/assinatura) e `DbookLiveAvailability` (widget) cada um com uma responsabilidade; comentário só onde o "porquê" não é óbvio (ex.: por que a auth é um header STOMP nativo e não HTTP, por que não há garantia de entrega)
- [x] Arquitetura — `dbook_feature_realtime` depende só de `dbook_core_session`/`dbook_design_system`; `DbookRealtimeSocket` isola o `WebSocketChannel` de verdade atrás de uma porta fina, testável sem servidor real; a integração com `FlightDetailPage` é via widget injetado pelo app, mesmo padrão das outras features
- [x] Componentização — o indicador usa só `Text`/`Container` simples (não há um componente de design system pra "dot de status ao vivo" ainda — decidido não criar um componente novo pra um único uso; se aparecer de novo, sobe pro `dbook_design_system`) com tokens (`DbookSpacing`) pro espaçamento
- [x] Layout — espaçamento vem de `DbookSpacing`, sem número solto
- [x] Material Design — não se aplica reconstrução de widget nativo aqui (é só texto + um indicador visual pequeno)
- [x] `analyze` + `format` + `test` limpos — 12 pacotes, `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — `StompFrame` (serialize/parse, round-trip), `StompAvailabilityClient` (CONNECT com token, SUBSCRIBE após CONNECTED, MESSAGE vira `live`, ERROR vira `unavailable`, desconexão→reconexão com backoff via `fake_async`, dispose fecha o socket), `DbookLiveAvailability` (mostra a atualização ao vivo) e o novo slot `FlightDetailPage.liveAvailability`
- [x] README atualizado — [README.md](README.md) com `dbook_feature_realtime` na estrutura e progresso do M6
- [x] Cobertura mínima — combinado: **84.77%** (1842/2173 linhas); `dbook_feature_realtime` sozinho: 91.11%

## M7 — Sugestão por IA ✅

Decisão: `AiSuggestion` (`POST /ai/suggestions`) só devolve `{flightId, reason}` — sem os dados do voo embutidos, e sem `GET /flights/{id}` pra completar depois (mesmo buraco de contrato do M4/M5). A lista mostra exatamente o que a API devolve ("Flight #42" + motivo), sem fingir ter uma busca de voo por trás.

- [x] 7.1 Criar o pacote `packages/dbook_feature_ai`
- [x] 7.2 Campo de busca em linguagem natural — `DbookSearchField` (M1, já documentado como construído pra este uso exato)
- [x] 7.3 Implementação real do `AiSuggestionRepository` — já existia desde o M2 (`AiSuggestionRepositoryImpl`); só faltava o provider ligando ao Dio autenticado
- [x] 7.4 Riverpod: `AiSuggestionNotifier` (estados idle/loading/success/error)
- [x] 7.5 Lista de sugestões (voo + motivo, usando o `dbook_design_system`) — `AiSuggestionPage`, com `DbookStatusPlaceholder` pros estados vazio/erro (com retry) e `DbookLoadingIndicator` pro loading
- [x] 7.6 Tratamento de erro específico: 429 (rate limit), 502/503 (modelo indisponível) — `DbookNetworkException.message` já carrega a mensagem do backend pra cada um (mapeados desde o M2); mesmo padrão uniforme dos outros notifiers, sem tratamento especial por código

**Checklist de fechamento do M7:**
- [x] Itens 7.1-7.6 revisados — todos `[x]`
- [x] Clean Code — `AiSuggestionNotifier` só orquestra estado; comentário só onde o "porquê" não é óbvio (ex.: por que a lista mostra `flightId` cru em vez de dados do voo)
- [x] Arquitetura — `dbook_feature_ai` depende só de `dbook_domain`/`dbook_core_network`/`dbook_core_session`/`dbook_design_system`; a ação "Ask DBook AI" na busca de voos é injetada pelo app, mesmo padrão de `myBookingsAction`/`logoutAction`
- [x] Componentização — a tela usa só `DbookAppBar`/`DbookSearchField`/`DbookStatusPlaceholder`/`DbookLoadingIndicator` do `dbook_design_system`, e `Card`/`ListTile` nativos já temáticos pro item da lista (não há um componente de design system pra "item de sugestão da IA" ainda — decidido não criar um novo componente pra um único uso com só ícone+título+subtítulo, que é exatamente o que `ListTile` já faz)
- [x] Layout — espaçamento vem de `DbookSpacing`
- [x] Material Design — `TextField` (via `DbookSearchField`)/`Card`/`ListTile` nativos via tema
- [x] `analyze` + `format` + `test` limpos — 13 pacotes, `melos run test` (Flutter) e `melos run test:dart` (Dart puro) verdes
- [x] Testes das camadas ainda sem cobertura — `AiSuggestionNotifier` (sucesso, 429, 503) e `AiSuggestionPage` (idle, sucesso, vazio, erro com retry)
- [x] README atualizado — [README.md](README.md) com `dbook_feature_ai` na estrutura e progresso do M7
- [x] Cobertura mínima — combinado: **85.04%** (1898/2232 linhas); `dbook_feature_ai` sozinho: 94.64%

## M8 — CI/CD ✅

Decisão: só entra depois que o app já builda e roda de ponta a ponta manualmente — mesmo princípio do M8 do backend ("só automatiza depois que já validou na mão"). Como o `gh` não estava autenticado neste ambiente, dois passos ficaram só preparados no código, pendentes de o usuário rodar os comandos direto no GitHub (não é algo que Claude consegue fazer sem essa autenticação) — ver "Pendente" abaixo.

- [x] 8.1 Build de APK debug automatizado no pipeline (a cada push) — job `build-android` no `ci.yml`
- [x] 8.2 Build de APK release assinado (keystore via secret do GitHub) — `build.gradle.kts` lê `key.properties` (gerado pela CI a partir dos secrets `ANDROID_KEYSTORE_BASE64`/`ANDROID_KEYSTORE_PASSWORD`/`ANDROID_KEY_ALIAS`/`ANDROID_KEY_PASSWORD`, ou de um arquivo local pra dev), com fallback pra assinatura de debug se não existir — testado localmente de ponta a ponta com um keystore de verdade (`apksigner verify` confirmou a assinatura); **pendente**: usuário precisa cadastrar os 4 secrets no repo (comandos prontos, fora do chat)
- [x] 8.3 Build de IPA no pipeline — se houver Mac runner disponível — job `build-ios` (`macos-latest`), `flutter build ios --release --no-codesign` (testado localmente); sem certificado/perfil da Apple Developer Program neste repo não dá pra assinar um `.ipa` de verdade, então o job só valida que compila e arquiva
- [x] 8.4 Gate de qualidade completo bloqueando merge (`analyze` + `format` + `test` + cobertura mínima) — a CI já roda tudo isso em todo push/PR pra `main` desde o M1; **pendente**: usuário precisa ativar branch protection no GitHub exigindo o check `analyze-format-test` (comando pronto, fora do chat) — sem isso, o gate é só informativo, não bloqueia de verdade

**Checklist de fechamento do M8:**
- [x] Itens 8.1-8.4 revisados — código e workflow prontos; 2 ativações no GitHub pendentes do usuário (ver acima)
- [x] Clean Code — `build.gradle.kts` cai pra assinatura de debug sem `key.properties`, nunca quebra o build por falta de configuração; comentário só onde o "porquê" não é óbvio (por que sem certificado Apple o job de iOS só valida compilação, por que o fallback de assinatura existe)
- [x] Arquitetura — não se aplica (CI/CD, sem código de app novo)
- [x] Componentização — não se aplica neste marco
- [x] Layout — não se aplica neste marco
- [x] Material Design — não se aplica neste marco
- [x] `analyze` + `format` + `test` limpos — nada mudou no lado Dart, só `build.gradle.kts`/workflow; 13 pacotes seguem verdes
- [x] Testes das camadas ainda sem cobertura — não se aplica (infraestrutura de build, não lógica de app)
- [x] README atualizado — [README.md](README.md) com a seção de CI/CD e as instruções dos secrets
- [x] Cobertura mínima — inalterada (não há código Dart novo neste marco); segue em **85.04%**, verificado pelo próprio gate da CI (`very_good_coverage`, mínimo 80%)

## M9 — Remediação de navegação e UX ⬜

Decisão: revisão crítica (2026-09-12) encontrou o app bloqueando busca/
resultados/detalhe atrás de login, contrariando o próprio contrato do
backend (`GET /flights/search` e `GET /bookables/{id}/seats` são
`permitAll()` em `SecurityConfig.kt`) — nenhum concorrente real exige
conta pra ver preço. Auditoria completa e causa raiz de cada item em
`docs/m9_remediation_spec.md` (mesmo documento aprovado como plano).
Escopo negativo explícito: pagamento real, alteração de reserva com
diferença de preço, check-in, favoritos, notificações, configurações de
conta, hotéis/carros/experiências e deep link pra voo/reserva específica
ficam de fora desta rodada — nenhum tem endpoint no backend, e construir
a tela sem o backend repetiria o erro que motivou esta revisão.

- [x] 9.1 Auth Gate real — `_AppRoot` para de decidir qual tela mostrar por `AuthState`; visitante busca, vê resultados e detalhe sem login; gate dispara em "Book This Flight" (preservando o `Flight` selecionado), em "Ask DBook AI" (`POST /ai/suggestions` exige sessão, achado corrigido depois de checar `AiSuggestionController.kt`), em "My Bookings" e no ícone avulso "Entrar"; bootstrap de sessão para de bloquear o primeiro frame; onboarding roda uma vez só (flag local via `shared_preferences`); `pushAuthGate` (helper único) garante back-stack coerente — testado ponta a ponta em `widget_test.dart` (12 casos) e visualmente no Browser pane
- [x] 9.2 Ação fixa no rodapé (`Scaffold.bottomNavigationBar`) em `FlightDetailPage` (preço + botão juntos, como na tela 06 do kit) e no resumo de `SeatSelectionPage` (extraído pra `_SeatSelectionFooter`) — troca de botão solto no fim da `Column`, sem quebrar nenhum teste existente. **Exceção em `FlightSearchPage`** (pedido explícito do usuário depois de comparar com a referência visual): o botão "Search Flights" vive dentro do próprio `DbookTripSummaryCard` (novos parâmetros `searchLabel`/`onSearch`), não mais solto num `bottomNavigationBar` — só nessa tela
- [x] 9.3 Shell do app: `IndexedStack` de 4 abas (Home/Explore/Trips/Profile, sempre visíveis) + `NavigationBar`, usando `navigationBarTheme` (temado desde o M1, nunca consumido); Drawer (`drawerTheme`, idem) acessível pela Home com "Ask DBook AI" e Sair/Entrar — App bar de `FlightSearchPage` perdeu os ícones soltos (myBookings/aiSuggestions/logout), tudo migrou pro Drawer ou virou aba própria; Trips/Profile mostram `DbookStatusPlaceholder` + CTA "Entrar" pra visitante em vez de exigir login pra ver a aba — testado em `widget_test.dart` (16 casos)
- [x] 9.4 Home ganha "Destinos em destaque" (grade de 2 colunas, `DestinationCard` — foto em cima, nome/país embaixo) acima do card de busca; tocar preenche o destino da busca direto
- [x] 9.5 Aba Explore — mesma grade dos 3 aeroportos conhecidos; tocar seta um provider efêmero (`prefillDestinationProvider`, `Notifier` — `StateProvider` não existe mais no Riverpod 3.x deste projeto) que a Home consome via `ref.listen` (não `initState`: a Home fica montada o tempo todo no `IndexedStack`, então só `ref.listen` continua reagindo depois do primeiro build) e volta pra aba Home com o destino pré-preenchido
- [x] 9.4/9.5 fotos reais — 3 fotos Unsplash (São Paulo/GRU, Rio/GIG, New York/JFK) confirmadas com o usuário antes de usar, mesmo processo do M1; carregadas via URL direta do CDN (`KnownAirport.photoUrl` + `NetworkImage`, sem asset bundled — pedido explícito do usuário), com fallback pro degradê quando `photoUrl` é nulo. Créditos em `packages/dbook_feature_flights/docs/destination_photo_credits.md`
- [x] Revisão visual adicional (fora da numeração, pedida pelo usuário depois de comparar com um app de referência gerado no Figma Make): reaproveitadas só as partes compatíveis com o backend — header hero azul com logo/tagline na Home, linha pontilhada + ícone de avião conectando horários no card de resultado (`DbookFlightResultTile`) e no detalhe do voo, header em bloco azul no Profile. Ficaram de fora abas Fly/Sleep/Eat, banner de ofertas, preço nos cards de destino, "Explore by Region", filtro/seletor de dia nos resultados, taxa de bagagem, stats e menu fake do Profile — nenhum tem endpoint no backend
- [x] Tipo de viagem — Round Trip/One Way/Multi-city implementados (`_TripType`, `DbookTripSummaryCard.returnDateLabel`), com revisão do usuário depois de 3 entregas com nota baixa (3, depois 5, depois 0 duas vezes no Multi-city especificamente — corrigido só depois de pesquisar o comportamento real do Google Flights, ver `feedback_selfreview_before_delivery.md`): grade de "Destinos em destaque" corrigida (`DestinationCardGrid` calcula a altura da célula em vez de um `childAspectRatio` fixo, eliminando espaço vazio), botão de busca movido pra dentro do card (ver exceção do item 9.2), Multi-city começa com 1 trecho só e encadeia a origem do próximo a partir do destino anterior (mesmo comportamento do Google Flights), e **implementado como N compras reais e independentes encadeadas** (não decorativo): cada trecho extra (seção dentro do mesmo `DbookTripSummaryCard` via `extraContent`, layout confirmado com o usuário) passa pelos mesmos endpoints reais que o fluxo de 1 trecho (`GET /flights/search` → `GET /bookables/{id}/seats` → `POST /bookings`), encadeado via `BookingSuccessPage.onNextLeg`/`SeatSelectionPage` (novos parâmetros opcionais) e orquestrado em `_AppShellState._searchNextLeg` (root navigator, fora do `go_router` interno da Home) — cada trecho vira reserva separada, visível na aba Trips. **Radios de tipo de viagem desativados na UI por pedido do usuário** (`_TripTypeRow.enabled: false`, `IgnorePointer`+`Opacity`) até uma próxima revisão — trava em Round Trip; a lógica de Multi-city continua implementada e coberta por teste (`skip: _tripTypeDisabled` nos 4 cenários que dependiam do rádio, não apagados), só inacessível pela UI por enquanto. Confirmado visualmente no Browser pane (2026-09-13): rádios aparecem esmaecidos e não respondem a toque
- [ ] 9.6 Review Order — novo, entre seleção de assento e confirmação; resumo real, **sem campo de pagamento** (não existe endpoint de pagamento no backend), confirma e chama `POST /bookings` de verdade
- [x] 9.7 (parcial) Profile — e-mail capturado no login/registro (`AuthState.loggedIn.email`, só sessão — sem `GET /users/me`, fica `null` se a sessão veio do bootstrap); `/trips/{id}` (detalhe de uma reserva) ainda não construído
- [ ] 9.8 Polimento client-side: ordenar/filtrar resultado já buscado (sem parâmetro novo na API) e banner de offline (`connectivity_plus` + `DbookInlineStatusBanner`, já existe)
- [x] 9.9 Grade "Destinos em destaque" (`DestinationCard`, `destination_grid_card.dart`) ganha preço real ("from $X", menor preço do destino via `lowestPriceProvider`/`GET /flights/lowest-price` do M12 do backend) e favorito local (`FavoriteDestinationsNotifier`, `shared_preferences` — sem endpoint de favoritos no backend, decisão: não é dado que precisa sincronizar entre dispositivos nesta fase). Testado de ponta a ponta no Browser pane com backend real e dados seedados: São Paulo/Rio/New York mostraram exatamente os preços confirmados via `curl` ($730/$382/$422), toque no coração encheu de vermelho e sobreviveu a um reload completo da página. Achado durante essa verificação e corrigido no backend: `SecurityConfig` nunca teve CORS configurado — nenhum request de browser chegava em nenhum endpoint (ver nota no `CHECKLIST.md` do `dbook`, M12)

**Checklist de fechamento do M9:**
- [ ] Itens 9.1-9.8 revisados
- [ ] Clean Code
- [ ] Arquitetura (features seguem sem se importar entre si; Auth Gate mora no app, não em feature)
- [ ] Componentização (zero widget novo fora do `dbook_design_system` sem necessidade real — reaproveitar o que já existe antes de criar componente novo)
- [ ] Layout (ação sempre fixa no rodapé, sem número solto)
- [ ] Material Design (`NavigationBar`/`Drawer` nativos via tema, não reconstruídos)
- [ ] `analyze` + `format` + `test` limpos, incluindo `apps/dbook_mobile/test/widget_test.dart` reescrito pro fluxo sem login obrigatório
- [ ] Comparação visual lado a lado com o UI kit de referência no Browser pane, tela por tela alterada — não só os testes automatizados
- [ ] README atualizado
- [ ] Cobertura mínima

## M10 — Tela de Resultados da Busca (redesign) ✅

Decisão (2026-09-12): redesign da `FlightResultsPage` a partir de uma
referência visual real compartilhada pelo usuário (cabeçalho com botão
Filter, faixa de datas com preço, contagem de voos + selo de melhor
preço, selo de companhia colorido por card). Duas decisões fechadas com
o usuário antes de começar:
- **Companhia aérea**: dado real, não inventado no mobile — depende do
  M11 do backend (`dbook`), que adiciona `Airline` seguindo o mesmo
  padrão de `Airport`.
- **Faixa de datas**: preços reais, não decorativos — cada data da
  faixa (±2 dias da data buscada) dispara sua própria busca em
  `GET /flights/search` (endpoint já existe, aceita só uma data exata
  por chamada — sem endpoint novo no backend), mostrando o menor preço
  real encontrado; tocar numa data refaz a busca principal pra ela.

- [x] 10.1 `Flight` (domínio Flutter) ganhou `airlineName`/`airlineIataCode`, espelhando o `FlightResponse` novo do M11 do backend
- [x] 10.2 Cabeçalho via `DbookAppBar(title:, subtitle:)` — "origem → destino" + "data · passageiros" — com botão Filter nas `actions` (bottom sheet de ordenar por preço/duração e filtrar por classe de cabine sobre os resultados já buscados, sem parâmetro novo na API)
- [x] 10.3 Faixa de datas horizontal rolável (±2 dias, `dateStripProvider`/`DateStripQuery`), uma busca real (`GET /flights/search`) por data, menor preço encontrado em cada chip; tocar numa data recentraliza a faixa e refaz a busca principal pra ela
- [x] 10.4 Contagem "N flights found" + selo "Best prices today" (só aparece quando o preço do dia selecionado é de fato o menor da faixa visível — comparado contra `dateStripProvider`, nunca decorativo)
- [x] 10.5 `DbookFlightResultTile` ganhou `airlineIataCode`/`airlineColor` — selo quadrado colorido com o código IATA em vez do ícone genérico; cor fixa por companhia conhecida (`_knownAirlineColors`, as 6 do seed do M11 do backend) com fallback por hash pra qualquer código novo — evita duas companhias diferentes caindo na mesma cor por coincidência
- [x] 10.6 Testes: `dbook_flight_result_tile_test.dart` (selo colorido), `flight_results_page_test.dart` ganhou 3 cenários novos (preço real por dia + selo "Best prices today", troca de dia recarrega a lista, filtro por classe muda a contagem) — 7 cenários no total, todos passando; corrigidos 2 bugs reais achados pelos próprios testes: a faixa de datas ficava girando pra sempre quando a busca falhava (nunca tratava `AsyncError`), e a folha de filtro estourava a altura da tela (sem `SingleChildScrollView`)
- [x] 10.7 Revisão visual no Browser pane com backend real e dados seedados: cabeçalho, faixa de datas, contagem+selo, selos coloridos de companhia e o filtro (ordenar/filtrar) testados de ponta a ponta — bateu uma inconsistência real durante a própria revisão (LATAM e United caindo na mesma cor por hash) e foi corrigida ali mesmo (item 10.5)

**Checklist de fechamento do M10:**
- [x] Itens 10.1-10.7 revisados
- [x] Clean Code
- [x] Arquitetura (`dbook_feature_flights` não passou a depender de nada novo fora do padrão já usado — `shared_preferences` já tinha entrado no M9 pro favorito)
- [x] Componentização (`DbookFlightResultTile` estendido em vez de um componente novo; `DbookAppBar` já suportava título+subtítulo+actions, não precisou de header customizado)
- [x] Layout
- [x] Material Design
- [x] `analyze` + `test` limpos em todo o workspace (`melos exec -- flutter analyze` e `melos run test`)
- [x] Comparação visual lado a lado com a referência no Browser pane — não só testes automatizados
- [x] README atualizado — seção Progresso ganhou M9 (parcial) e M10
- [x] Cobertura mínima — combinado: **82.95%** (2427/2926 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M11 — `Destination` substitui `KnownAirport` (front burro) ✅

Decisão (2026-09-13): `knownAirports` era uma lista fixa de 3 aeroportos
hardcoded no Flutter — dado de negócio vivendo no front, contra o pedido
explícito do usuário ("front deve ser burro e não ter regras de
negócio"). Depende do M13 do backend (`dbook`), que expõe
`GET /destinations` com aeroporto+foto+menor preço real numa resposta
só. Esse marco troca `KnownAirport` (dado estático) por `Destination`
(entidade de domínio alimentada pela API) em todo lugar que hoje usa a
lista fixa — busca, seletor de origem/destino, grade da Home, aba
Explore — e cria 5 destinos novos de verdade (Londres, Paris, Lisboa,
Miami, Buenos Aires).

- [x] 11.1 `dbook_domain`: entidade `Destination` (iataCode, city, country, photoUrl, lowestPrice) + porta `DestinationRepository.getFeaturedDestinations()`; **remove** `FlightRepository.getLowestPrice` (responsabilidade de preço por destino migra inteira pra `DestinationRepository`) — reaproveitou a entidade `Airport` que já existia sem uso (código morto) em vez de criar `Destination` do zero (`git mv` + rename)
- [x] 11.2 `dbook_core_network`: `DestinationResponseDto` + `DestinationRepositoryImpl` (`GET /destinations`); **remove** `LowestPriceResponseDto`/`FlightRepositoryImpl.getLowestPrice` (código morto depois da troca)
- [x] 11.3 `dbook_feature_flights`: apaga `known_airports.dart`; `flight_providers.dart` troca `lowestPriceProvider` (família, 1 chamada por destino) por `featuredDestinationsProvider` (1 chamada só); `DestinationCardGrid`/`DestinationCard`/`destination_gradient.dart`/`airport_picker_sheet.dart` passam a receber `Destination` em vez de `KnownAirport`
- [x] 11.4 `explore_page.dart` vira `ConsumerWidget` com loading/erro de verdade (antes era estático, não precisava); `flight_search_page.dart`: `_origin`/`_destination` iniciam `null` e se auto-preenchem quando `featuredDestinationsProvider` resolve pela 1ª vez (`ref.listen`, só se o usuário ainda não escolheu nada); pull-to-refresh passa a invalidar 1 provider só (`ref.refresh(featuredDestinationsProvider.future)`)
- [x] 11.5 `main.dart`: `_selectExploreDestination` recebe `Destination`
- [x] 11.6 Testes atualizados pra `destinationRepositoryProvider.overrideWithValue(...)` em vez de rastrear chamada por código IATA (mais simples que os fakes de preço de hoje) — `flight_search_page_test.dart`, `flight_results_page_test.dart`, `destination_grid_card_test.dart` e `widget_test.dart` (app) migrados
- [x] 11.7 Revisão visual no Browser pane: Home/Explore/seletor de busca mostrando os 8 destinos com foto/preço real

**Bug encontrado e corrigido durante a revisão visual:** `airport_picker_sheet.dart` usava um `Column` com `mainAxisSize: MainAxisSize.min` e um `for` direto sobre a lista — funcionava com 3 aeroportos fixos, mas com os 8 destinos reais estourou o bottom sheet (`RenderFlex overflowed by 449 pixels`, visível só no Browser pane, não pego pelos testes automatizados porque eles não testam o tamanho real da tela). Corrigido trocando o `for` por `Flexible(child: ListView.builder(...))` e limitando a altura do sheet a 70% da tela (`constraints: BoxConstraints(maxHeight: ...)` em `showModalBottomSheet`).

**Outro problema encontrado (ambiente, não código):** o servidor de dev do Browser pane (`preview_start`) estava servindo um build antigo, anterior a toda a refatoração — a Home só mostrava 3 destinos e a rede batia em `/flights/lowest-price` (endpoint removido nesta sessão), não em `/destinations`. `flutter run` no modo Web Server não faz watch automático de mudanças em pacotes do monorepo; precisou de `preview_stop` + `preview_start` (restart completo, não hot reload) pra recompilar do zero e pegar o código novo.

**Checklist de fechamento do M11:**
- [x] Itens 11.1-11.7 revisados
- [x] Clean Code
- [x] Arquitetura (front sem dado fixo de negócio — só renderiza o que a API manda; `Destination` inteiro vem de `GET /destinations`, incluindo foto)
- [x] Componentização (`airport_picker_sheet.dart` ganhou scroll de verdade em vez de crescer sem limite)
- [x] Layout
- [x] Material Design
- [x] `analyze` + `test` limpos em todo o workspace (`melos exec -- flutter analyze` e `melos run test`)
- [x] Comparação visual lado a lado no Browser pane — Home (grade "Destinos em destaque" com os 8 + "Mais destinos"), Explore (mesma grade) e o seletor de origem/destino da busca, todos com foto e preço reais, sem overflow
- [x] README atualizado
- [x] Cobertura mínima — combinado: **82.29%** (2453/2981 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M12 — "Principais destinos" e "Destinos por região" (Explore + Home) ✅

Pedido do usuário, com uma referência visual (tela "04. Destinations"):
a aba Explore precisava separar os destinos em dois grupos — principais
destinos e destinos por região — em vez da grade única e flat que existia
desde o M11. Três idas e voltas de design até fechar:

1. Primeira proposta (região vinda do backend, um campo a mais em
   `Destination`) foi aprovada, mas ao começar a implementar ficou claro
   que "principais destinos" *também* precisava ser uma curadoria real,
   não a lista inteira — o usuário corrigiu: "não trazer tudo, alguns
   destinos populares e outro grupo destinos por região".
2. Isso levou a decidir `isPopular` do mesmo jeito que `region`: mais um
   atributo do `Destination` vindo do backend (M14 do `dbook`), não uma
   segunda lista. A alternativa mais simples — inventar "populares" como
   um corte arbitrário no front (ex.: os 3 primeiros) — foi descartada
   pelo mesmo motivo de sempre: seria dado de negócio decidido no
   Flutter, não no backend.
3. Depois de ver a Explore pronta, o usuário pediu a mesma estrutura na
   Home — "Destinos em destaque" (que até então mostrava a lista
   inteira, sem filtrar por `isPopular`) e "Mais destinos" (lista
   horizontal plana, sem noção de região) ficaram inconsistentes com a
   Explore recém-construída.
4. Com as duas telas prontas, o usuário apontou que "Destinos por
   região" ainda não era o que foi combinado: as regiões eram só seções
   estáticas (uma abaixo da outra, sempre todas visíveis), sem nenhuma
   interação — ele queria "região como filtro clicável". `DestinationsByRegion`
   foi reescrito de seções estáticas por região pra um filtro de fato:
   chips de seleção única ("Todos" + uma por região) acima de uma única
   grade que mostra só os destinos da região escolhida.
5. Depois de ver o filtro funcionando (na Home e na Explore), o usuário
   corrigiu de novo: na **Home** especificamente, o filtro de chips
   estava errado — o certo era um **carrossel com 1 card por região**
   (foto + nome), não um filtro. A Explore continua com o filtro de
   chips (não foi questionado); só a Home trocou. Confirmado com o
   usuário: tocar um card do carrossel leva pra Explore já filtrada
   naquela região — reaproveita o mesmo mecanismo de "ponte efêmera"
   já usado pra Explore→Home (`prefillDestinationProvider`), só que
   Home→Explore (`prefillRegionProvider`).

O resultado final: **uma chamada só** (`GET /destinations`, sem mudança),
`region`/`isPopular` chegam junto com cada destino. A Home mostra um
grid fixo (`isPopular`) + um carrossel de regiões (`RegionCarousel`,
sem filtro, só navegação); a Explore mostra o mesmo grid fixo + um
filtro de verdade por região (`DestinationsByRegion`, com chips). Tocar
um card do carrossel na Home seta `prefillRegionProvider` e troca pra
aba Explore, que já nasce com aquela região selecionada no filtro —
nenhum provider novo além dessa ponte efêmera, nenhum endpoint novo,
nenhuma lógica duplicada entre as duas telas.

- [x] 12.1 `Destination` (domínio) e `DestinationResponseDto` ganham `region`/`isPopular`, espelhando o M14 do backend
- [x] 12.2 `ExplorePage` reescrita: `_ExploreContent` filtra `destinations.where((d) => d.isPopular)` pra "Principais destinos" e usa `DestinationsByRegion` pra "Destinos por região"
- [x] 12.3 `DbookChipRow` (novo, `dbook_design_system`) — faixa horizontal de chips de seleção única, mesmo padrão visual do `DbookFareDateStrip` já existente (chip cheio quando selecionado); componente do design system antes da feature usar, não o contrário
- [x] 12.4 `DestinationsByRegion` (`dbook_feature_flights`) — `StatefulWidget` com estado próprio (`_selectedIndex`); monta os labels ("Todos" + `region`s distintas, ordenadas) pro `DbookChipRow` e filtra a lista pro `DestinationCardGrid` de acordo com o chip selecionado; widget compartilhado, não duplicado em cada tela
- [x] 12.5 `flight_search_page.dart` (Home): "Destinos em destaque" passa a filtrar `isPopular` (igual à Explore); "Mais destinos" (lista horizontal plana) removida e substituída por `DestinationsByRegion` — mesmo componente das duas telas, com estado de filtro independente em cada uma
- [x] 12.6 Testes: `destinations_by_region_test.dart` (novo) — todos aparecem sem filtro, tocar um chip filtra, voltar pra "Todos" mostra tudo de novo, tocar um destino dispara `onSelect`; `dbook_chip_row_test.dart` (novo, design system); fixtures de `Destination(...)` em todo o workspace ganham `region`/`isPopular`; `widget_test.dart` (app) e `flight_search_page_test.dart` ajustados — um destino popular aparece 2x na página (destaque + região, estado "Todos"), então o teste que toca nele usa `.first`
- [x] 12.7 `RegionCarousel` (novo, `dbook_feature_flights`) — carrossel horizontal, 1 card por `region` distinta (`DbookDestinationCard` reaproveitado, foto do 1º destino daquela região); `DbookDestinationCard.subtitle` virou opcional (o card de região não tem subtítulo, só a foto+nome — mudança pontual no design system, sem quebrar os usos existentes)
- [x] 12.8 `prefillRegionProvider` (novo, mesmo padrão de `prefillDestinationProvider`) — Home seta ao tocar um card do carrossel, `DestinationsByRegion` (agora `ConsumerStatefulWidget`) escuta via `ref.listen` e pré-seleciona o chip da região recebida; `main.dart._selectHomeRegion` troca a aba pra Explore, espelhando `_selectExploreDestination`
- [x] 12.9 `flight_search_page.dart` (Home): "Destinos por região" (filtro de chips) trocado por "Explore por região" (`RegionCarousel`, sem filtro — só navega); `FlightSearchPage`/`FlightsHomePage` ganham o parâmetro `onSelectRegion`, repassado até `main.dart`
- [x] 12.10 Testes: `region_carousel_test.dart` (novo) — 1 card por região, tocar dispara `onSelectRegion`; `widget_test.dart` (app) ganhou um teste de ponta a ponta — tocar "América do Norte" no carrossel da Home troca pra Explore com o chip "América do Norte" já selecionado (escopado a `DestinationsByRegion`, não à `ExplorePage` inteira — "São Paulo" continua aparecendo em "Principais destinos", que não passa pelo filtro de região); `dbook_destination_card_test.dart` ganhou o caso sem subtítulo
- [x] 12.11 `analyze` + `test` limpos em todo o workspace

**Checklist de fechamento do M12:**
- [x] Itens 12.1-12.11 revisados
- [x] Clean Code
- [x] Arquitetura (sem estrutura paralela — `region`/`isPopular` são atributos do mesmo `Destination`; a ponte Home→Explore reaproveita o mesmo padrão já usado pra Explore→Home)
- [x] Componentização (`DbookChipRow` no design system antes da feature; `DestinationsByRegion`/`RegionCarousel` cada um com sua responsabilidade — filtro na Explore, navegação na Home — sem duplicar a leitura de `region`)
- [x] Layout
- [x] Material Design
- [x] `melos exec -- flutter analyze` + `melos run test` limpos em todo o workspace
- [x] Comparação visual no Browser pane — Home mostra "Destinos em destaque" (4 cards) seguido de "Explore por região" (carrossel horizontal com foto real por região); tocar um card leva pra Explore com o chip daquela região já selecionado (testado com "Europa": chip fica azul, grade mostra só Londres/Paris/Lisboa)
- [x] README atualizado
- [x] Cobertura mínima — combinado: **82.17%** (2516/3062 linhas), acima do mínimo de 80%

## M13 — Perfil real ✅

Decisão (2026-09-14): o usuário revisou a parte logada do app contra 5
imagens de referência e apontou que o Perfil "não tem nada, não tem o
nome, não tem uma outra informação, não tem quase nada" — mostrava só o
e-mail digitado na sessão (nem sobrevivia a um F5, já que o bootstrap
recupera token mas não e-mail). Plano aprovado (Perfil real / assento por
modelo de avião / Minhas Viagens persistidas / resultados mais ricos —
M13 deste plano): `User` ganha `name` de verdade (M15 do backend, já
commitado), o app
busca o perfil real via `GET /users/me` em vez de reaproveitar só o que
o formulário digitou, e ganha "Editar Perfil" funcional
(`PATCH /users/me`). Decisão explícita: o Perfil mostra **só o que é
real** — avatar+nome+e-mail+Editar Perfil+Sair, sem os 7 itens
decorativos da imagem de referência (Travel Documents, Payment Methods,
Preferences, Notifications, Language, Currency, Help & Support) — nenhum
deles tem tela ou dado real por trás, e adicionar a lista inteira só pra
parecer a imagem violaria o mesmo princípio de "front burro" que guiou
o resto do app.

- [x] 13.1 `dbook_domain`: `User` ganha `name: String`; `AuthRepository` ganha `getMe()`/`updateName(String)` (mesma porta — mesmo agregado "sessão") e `register()` passa a exigir `name`
- [x] 13.2 `dbook_core_network`: `UserResponseDto`/`RegisterUserRequestDto` ganham `name`; `UpdateUserNameRequestDto` novo (`PATCH /users/me`); `AuthRepositoryImpl` implementa `getMe()`/`updateName()`
- [x] 13.3 `PersistingAuthRepository` passa a receber **dois** repositórios de rede — `networkRepository` (Dio sem token, login/registro/refresh) e `authenticatedRepository` (Dio com token, `getMe()`/`updateName()`) — descoberta na implementação: `/users/me` exige sessão ativa, então não dava pra reaproveitar o mesmo Dio "cru" que login/registro usam; `authRepositoryProvider` monta os dois (`authOnlyDioProvider` e `dioProvider` de `dbook_core_session`, respectivamente)
- [x] 13.4 `AuthState.loggedIn` ganha `name: String?`; `AuthNotifier` ganha `_syncProfile()` — chamado depois de `login()`/`register()`/`bootstrap()`, busca `GET /users/me` e substitui o que foi digitado pelos dados reais do servidor (também corrige o gap de `bootstrap()` não recuperar e-mail depois de reabrir o app); falha de rede no sync não derruba a sessão (token já é válido, só mantém o que já tinha); `updateName()` novo, chama `PATCH /users/me` e atualiza o estado
- [x] 13.5 `RegisterPage` ganha o campo "Nome" (validação simples de não-vazio, `AuthValidators.name`)
- [x] 13.6 `ProfilePage` (novo, `apps/dbook_mobile/lib/profile_page.dart`, extraído do `_ProfilePage` inline que vivia em `main.dart`) — `DbookAvatar` com iniciais do nome, nome (title) + e-mail (subtitle) reais, "Editar Perfil" (diálogo com `TextFormField`, chama `AuthNotifier.updateName`, mostra erro inline em caso de falha de rede), Sair — sem os itens decorativos da referência
- [x] 13.7 Testes: `auth_use_cases_test.dart` (`RegisterUseCase` com `name`), `persisting_auth_repository_test.dart` (login/registro/refresh continuam roteados pro repositório "cru"; `getMe()`/`updateName()` roteados pro autenticado — prova a decisão do item 13.3), `auth_notifier_test.dart` (sync de perfil após login/bootstrap, sync falho mantém sessão, `updateName` atualiza o estado), `register_page_test.dart` (campo Nome), `profile_page_test.dart` (novo — nome real exibido, fallback decente quando `name` vier vazio, editar funciona e atualiza o header, erro de rede mostrado inline sem fechar o diálogo)
- [x] 13.8 `melos exec -- flutter analyze` + `melos exec -- dart format --set-exit-if-changed .` + `melos run test` limpos em todo o workspace

**Checklist de fechamento do M13:**
- [x] Itens 13.1-13.8 revisados
- [x] Clean Code
- [x] Arquitetura (perfil continua no mesmo agregado "sessão" via `AuthRepository`/`AuthNotifier`, sem uma porta nova só pra 2 métodos; `getMe()`/`updateName()` nunca passam pelo Dio sem token)
- [x] `melos exec -- flutter analyze` + `melos run test` limpos em todo o workspace
- [x] Testado manualmente no Browser pane: cadastro com nome → Perfil mostra avatar com iniciais + "Diego Ferreira" + e-mail reais → Editar Perfil → novo nome salvo, header atualiza na hora → reload da página (bootstrap) → nome/e-mail continuam lá, vindos do `GET /users/me` de verdade (persistência real, não sessão)
- [x] README atualizado
- [x] Cobertura mínima — combinado: **81.79%** (2596/3174 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M14 — Assento por modelo de avião real ✅

Decisão (2026-09-14): a seleção de assento era só um `GridView` fixo de 6
colunas, sempre igual pra qualquer voo — "hoje só tem quadrados, está
muito pobre... verificar o modelo do avião... se o avião ele for de duas
fileiras com dois assentos, mostrar duas fileiras com dois assentos, se
for com duas fileiras e três assentos mostrar [o de verdade]". O backend
já resolve tudo isso desde o M16 (`aircraftType`/`seatLayout` reais em
todo `FlightResponse`); faltava o app agrupar por fileira/corredor em vez
de tratar a lista de assentos como um grid genérico.

- [x] 14.1 `Flight` (domínio) e `FlightResponseDto` ganham `aircraftType: String`/`seatLayout: List<int>` — passthrough puro, o front nunca calcula o mapeamento avião→layout, só recebe o array já resolvido (mesmo princípio de "front burro" do M16 do backend)
- [x] 14.2 `DbookSeatCell` redesenhada — 40×40 (antes 28×28 fixo), topo mais arredondado que a base (lembra o encosto de uma poltrona, sem tentar desenhar um ícone literal de avião), `label` novo e visível dentro da célula (antes não mostrava nada); mantém as 3 cores de estado (available/selected/occupied)
- [x] 14.3 `seat_selection_page.dart` reescrita: `_seatsByRow`/`_columnBlocksFor` (novos, privados) parseiam `seat.label` (regex `^(\d+)([A-Z])$`) e agrupam pelas letras de cada bloco do `flight.seatLayout` (`[3,3]` → A,B,C | D,E,F; `[3,4,3]` → A,B,C | D,E,F,G | H,I,J); número da fileira à esquerda, letras das colunas no topo, corredor visível entre blocos; fundo com cantos arredondados (`colorScheme.surfaceContainerHighest`) lembrando a seção transversal de uma cabine; mapa dentro de scroll horizontal+vertical pra caber aeronaves largas (10 assentos/fileira do Boeing 777) sem quebrar o layout em telas estreitas
- [x] 14.4 Testes: `dbook_seat_cell_test.dart` ganhou os casos de `label` (visível/ausente); `seat_selection_page_test.dart` ganhou 2+2 (Embraer E195, 1 corredor, 4 assentos) e 3+4+3 (Boeing 777, 2 corredores, 10 assentos) além dos 4 testes já existentes (seleção/reserva continuam funcionando exatamente como antes — mesma lógica de estado, só mudou o agrupamento visual); DTOs/fixtures de `Flight(...)` em todo o workspace ganharam `aircraftType`/`seatLayout`
- [x] 14.5 `melos exec -- flutter analyze` + `melos exec -- dart format --set-exit-if-changed .` + `melos run test` (Flutter) + `dart test` (pacotes Dart puros) limpos em todo o workspace

**Checklist de fechamento do M14:**
- [x] Itens 14.1-14.5 revisados
- [x] Clean Code
- [x] Arquitetura (backend continua a única fonte da regra fileira/corredor — `seatLayoutFor` só no `dbook`; o mobile só agrupa o array que já chega pronto, sem tabela própria de avião→layout)
- [x] `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace
- [x] Testado manualmente no Browser pane, ponta a ponta com dado real do backend: voo Boeing 777 (`aircraftType` real) mostra exatamente 10 assentos por fileira em 3 blocos (A-C, D-G, H-J) com 2 corredores, scroll horizontal revela as colunas H/I/J; voo Embraer E195 mostra exatamente 2+2 (A,B | C,D) com 1 corredor, cabe sem scroll; tocar um assento seleciona (célula fica azul) e atualiza o rodapé ("Book Seat 1D")
- [x] README atualizado
- [x] Cobertura mínima — combinado: **82.12%** (2668/3249 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M15 — Minhas Viagens persistidas, Próximas/Anteriores ✅

Decisão (2026-09-14): "Minhas Viagens" era só memória de sessão
(`BookingRecord`, populado por `MyBookingsNotifier.add()` a cada reserva
feita no app) — sumia ao reabrir o app, e não distinguia passado de
futuro. O usuário escolheu o escopo maior: persistir de verdade no
backend (`GET /bookings`, M17 do `dbook`) em vez de só guardar
localmente.

- [x] 15.1 `dbook_domain`: `MyBooking` (novo) — `id`, `status`, `flight: Flight`, `seat: Seat`, espelhando `MyBookingResponse` do backend; diferente de `Booking` (resposta de `POST /bookings`/`cancel`, só com ids) — a listagem já vem composta, a entidade reflete isso em vez de reaproveitar `Booking` pela metade. `BookingRepository` ganha `listMine(): Future<List<MyBooking>>`
- [x] 15.2 `dbook_core_network`: `MyBookingResponseDto` (novo, aninha `FlightResponseDto`/`SeatResponseDto` já existentes — só compõe); `BookingRepositoryImpl.listMine()` → `GET /bookings`
- [x] 15.3 `MyBookingsNotifier` deixou de ser `Notifier` só-aditivo (`add()`) e virou `AsyncNotifier<List<MyBooking>>` — `build()` busca `listMine()` de verdade; `cancel(id)` chama o backend e só re-busca a lista se der certo (erro propaga pra UI tratar, lista não muda). `SeatSelectionNotifier.confirmBooking` não monta mais um `BookingRecord` local: reserva, invalida `myBookingsNotifierProvider` (próxima leitura re-busca do backend) e segue pra tela de sucesso só com `booking`/`flight`/`seat` (sem depender da lista). `BookingRecord` (redundante com `MyBooking` agora que existe endpoint de verdade) foi removida — front burro: uma estrutura a menos duplicando o que o backend já compõe
- [x] 15.4 `MyBookingsPage` reescrita: `DbookChipRow` (Próximas/Anteriores, já existia no design system desde o M12) filtra client-side por `flight.departureTime` vs. `DateTime.now()`; cada card ganha foto do destino (cruza `flight.destinationIataCode` com a MESMA lista de `featuredDestinationsProvider` — repassada por `main.dart`, que já importa as duas features; sem fetch novo, gradiente de fallback quando o destino não está no catálogo ou quando a página é aberta de dentro da própria feature sem essa lista), selo colorido de companhia + `flight.aircraftType` real (do M16 do backend); pull-to-refresh (`RefreshIndicator`); estados de loading/erro/vazio tratados
- [x] 15.5 Testes: `my_bookings_notifier_test.dart` reescrito (lista vazia, lista com reservas, cancelar re-busca com o status certo, cancelamento rejeitado propaga e não re-busca); `seat_selection_notifier_test.dart` ajustado (confirmar invalida a lista, sem popular nada localmente); `my_bookings_page_test.dart` reescrito com `testWidgetsWithMockImages` (novo helper `test/support/mock_network_image.dart`, mesmo padrão de `dbook_feature_flights`) — vazio, pendente com cancelar, confirmada sem cancelar, split Upcoming/Past (reserva passada só aparece em Anteriores), cancelar com sucesso re-busca e mostra cancelada, cancelar rejeitado mostra snackbar e mantém pendente, foto real do destino quando presente no catálogo
- [x] 15.6 `melos exec -- flutter analyze` + `dart format --set-exit-if-changed .` + `melos run test` (Flutter) + `dart test` (Dart puro) limpos em todo o workspace

**Checklist de fechamento do M15:**
- [x] Itens 15.1-15.6 revisados
- [x] Clean Code
- [x] Arquitetura (sem estrutura paralela — `MyBooking` é a única representação de "minhas reservas"; nenhuma lógica de negócio nova no front, `Upcoming`/`Past` é só um filtro de data client-side sobre o que o backend já manda; foto do destino reaproveita a lista que a Home/Explore já carregaram, sem fetch duplicado)
- [x] `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace
- [x] Testado ponta a ponta: registrar → reservar um voo real → Minhas Viagens (aba Trips, com foto real do destino cruzada) mostra a reserva em "Próximas" com companhia+modelo do avião corretos → cancelar e reabrir a lista (via `GET /bookings` direto, equivalente a reabrir o app) confirma o status `CANCELLED` persistido de verdade no backend, não só em memória (a etapa final do cancelamento *dentro* do Browser pane foi interrompida por uma instabilidade do próprio painel ficar oculto — verificação completada via chamada direta à API com o mesmíssimo fluxo, mais a suíte de testes automatizados que já cobre esse caminho)
- [x] README atualizado
- [x] Cobertura mínima — combinado: **81.69%** (2744/3359 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M16 — Resultados de busca mais ricos ✅

Decisão (2026-09-14): último marco do plano aprovado — o usuário achou os
resultados de busca "muito pobre na questão de massa", pedindo mais
volume/detalhe. A tela já tinha tudo que precisava de dado real
(companhia, horário, duração, preço, vagas); faltava só mostrar o
`aircraftType` real (M16 do backend) e ajustar a densidade dos dados de
seed.

- [x] 16.1 `DbookFlightResultTile` (design system) ganha `aircraftType` opcional — quando informado, uma linha extra abaixo dos horários (nunca inventado pelo front, só exibe o que já vier resolvido do backend)
- [x] 16.2 `flight_results_page.dart` repassa `flight.aircraftType` real pro tile
- [x] 16.3 `scripts/seed-flights.sh` (backend `dbook`) — janela de `days_ahead` reduzida de 1-60 pra 1-21 dias (mesma quantidade de voos, quase triplica a densidade por rota+data); addendum registrado no `CHECKLIST.md` do backend (M16, item 16.9)
- [x] 16.4 Testes: `dbook_flight_result_tile_test.dart` ganha os casos com/sem `aircraftType`
- [x] 16.5 `melos exec -- flutter analyze` + `dart format --set-exit-if-changed .` + `melos run test` limpos nos pacotes tocados

**Checklist de fechamento do M16:**
- [x] Itens 16.1-16.5 revisados
- [x] Clean Code
- [x] Arquitetura (front continua só exibindo o que o backend resolve — nenhuma tabela de avião→modelo nova no mobile)
- [x] `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace
- [x] Testado manualmente no Browser pane: reseed (+300 voos na janela de 21 dias) e busca GRU→GIG mostrando "Airbus A320" como linha extra em cada card de resultado, densidade de voos por data visivelmente maior
- [x] README atualizado
- [x] Cobertura mínima — combinado: **81.69%** (2748/3364 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M17 — Round Trip real + Anteriores por status ✅

Decisão (2026-09-14): revisão pós-plano, duas correções apontadas pelo
usuário testando o app:

1. "round trip seria ida e volta" — o campo "Return" de Round Trip era
   só cosmético: `_search()` sempre devolvia 1 trecho só, a volta nunca
   era buscada nem reservada. A infraestrutura de "encadear o próximo
   trecho depois de reservar" já existia pro Multi-city (M9);
   simplesmente nunca tinha sido ligada ao Round Trip.
2. "voos passados, cancelados, diferente de pendentes vão para a sessão
   anteriores" — Minhas Viagens (M15) separava Próximas/Anteriores só
   pela data do voo; uma reserva cancelada de um voo ainda no futuro
   ficava presa em "Próximas", mesmo não sendo mais uma viagem de
   verdade a caminho.

- [x] 17.1 `_search()` (`flight_search_page.dart`) — Round Trip agora sempre devolve 2 `FlightSearchQuery`: ida (como já era) + volta (destino→origem, na `_returnDate`); reaproveita a MESMA fila de "próximo trecho" (`onQueueLegs`/`_pendingLegs`/`SeatSelectionPage.onNextLeg`) que o Multi-city já usa — nenhuma lógica de encadeamento nova, só o Round Trip passou a alimentar a fila que já existia
- [x] 17.2 Bug real encontrado testando: `DbookSuccessScreen` estourava a altura da tela (`RenderFlex overflow`) com o rótulo de ação primária mais longo da volta ("Search Next Flight: Rio de Janeiro (GIG) → São Paulo (GRU)") — o `Column` central não tinha como rolar. Corrigido com `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight: ...)`: conteúdo continua centralizado quando cabe, rola em vez de vazar quando não cabe
- [x] 17.3 `my_bookings_page.dart` — nova `_isUpcoming(booking, now)`: "Próximas" exige voo no futuro **e** reserva não cancelada; uma reserva cancelada cai em "Anteriores" mesmo com `departureTime` futuro
- [x] 17.4 Testes: `flight_search_page_test.dart` (Round Trip padrão reporta 2 trechos, ida/volta com origem-destino invertidos e datas diferentes); `dbook_success_screen_test.dart` (rótulo longo numa tela pequena não lança exceção — regressão do overflow); `my_bookings_page_test.dart` (reserva cancelada com data futura só aparece em Anteriores; teste de cancelar reescrito pra refletir que a reserva muda de aba depois de cancelada)
- [x] 17.5 `melos exec -- flutter analyze` + `dart format --set-exit-if-changed .` + `melos run test` limpos em todo o workspace

Segunda rodada de feedback (mesmo dia): "consigo reservar só uma passagem,
o ideal seria eu escolher o voo de ida, depois o voo de volta e depois
os assentos de ida e de volta" — a ordem original (17.1) era voo→assento→
confirma→"próximo voo" repetido por trecho; o usuário queria os DOIS
voos escolhidos antes de QUALQUER assento.

- [x] 17.6 `main.dart` reestruturado: `_bookFlight` virou `_selectFlight` — quando ainda falta escolher o voo de outro trecho, vai direto pros resultados do próximo trecho (`_buildResultsPage`, sem passar por assento); só quando o ÚLTIMO voo da jornada é escolhido é que a seleção de assento começa (`_buildSeatSelectionFor`), um trecho de cada vez, encadeada pelo mesmo `nextLegLabel`/`onNextLeg` do `SeatSelectionPage`/`BookingSuccessPage` (nenhum widget novo, só o que constrói a próxima página mudou de "buscar" pra "escolher assento de um voo já escolhido"). De quebra corrigiu um bug latente: `isLoggedIn` deixou de ser propagado com o valor "congelado" de antes do login (podia reabrir o Auth Gate à toa no trecho seguinte) — depois do primeiro gate, sempre `true`
- [x] 17.7 `booking_success_page.dart`: rótulo do botão trocou de "Search Next Flight: X" pra "Choose Seat: X" — reflete que o próximo voo já foi escolhido, não precisa buscar de novo
- [x] 17.8 Testes: `booking_success_page_test.dart` (novo — sem próximo trecho mostra "View My Bookings"; com próximo trecho mostra "Choose Seat: X" e dispara `onNextLeg`); `widget_test.dart` (as duas cenas de Auth Gate reescritas pra escolher os dois voos antes do assento aparecer)

**Checklist de fechamento do M17:**
- [x] Itens 17.1-17.8 revisados
- [x] Clean Code
- [x] Arquitetura (Round Trip não ganhou lógica de encadeamento própria — reaproveita a mesma fila do Multi-city; `DbookSuccessScreen`/`SeatSelectionPage`/`BookingSuccessPage` continuam componentes burros, só o que os alimenta mudou)
- [x] `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace
- [x] Testado ponta a ponta no Browser pane (fluxo final): busca Round Trip → escolhe o voo de ida (GRU→GIG) → vai direto pros resultados da volta (sem assento ainda) → escolhe o voo de volta (GIG→GRU) → SÓ AGORA seleção de assento da ida → confirma (assento 1D) → tela de sucesso mostra "Choose Seat: GIG → GRU" → toca, vai direto pra seleção de assento da volta (sem buscar de novo) → confirma (assento 1B) → "View My Bookings" → Minhas Viagens mostra as duas reservas reais e independentes
- [x] README atualizado
- [x] Cobertura mínima — combinado: **82.18%** (2780/3383 linhas), acima do mínimo de 80% do gate de CI (`very_good_coverage`)

## M18 — Assento vira detalhe, revisão + pagamento no final ✅

Decisão (2026-09-15): o usuário mandou 3 imagens de referência (barra de
ação de pagamento, tela de pagamento completa, detalhe de voo rico) e
pediu "a seleção poderia ser um detalhe e vamos adicionar uma tela de
pagamento". Perguntei o escopo por `AskUserQuestion` e o usuário fechou
em duas decisões: **suporte real no backend** (não só UI) e **uma
revisão/pagamento só no final**, cobrindo os dois trechos de uma Round
Trip de uma vez — não uma tela de pagamento por trecho.

`Booking.confirm()` (backend) já existia mas era código morto — nenhuma
reserva saía de PENDING pra CONFIRMED. Pagar é o gatilho que faltava.

**Decisão de escopo (front burro):** as imagens de referência mostram
uma linha "Taxes & Fees" e um checkbox "Save card for future
purchases". Nenhum dos dois tem dado ou função real por trás — não
existe cálculo de taxa no backend, nem cofre de cartão. Por isso o
Resumo do Pedido mostra só o preço real de cada voo + total, sem
checkbox de salvar cartão.

- [x] 18.1 Backend `dbook` (M18, repositório irmão): `Payment` real, migration `V20__create_payment.sql` (tabela `payment` + `booking.payment_id`), `Booking.confirm(paymentId)` deixa de ser código morto, `RegisterPaymentUseCase` (soma `booking.bookable.price` de cada reserva, confirma todas numa `@Transactional`), `POST /payments` — ver `CHECKLIST.md` do backend
- [x] 18.2 `dbook_domain`: `Payment` (mirror do `PaymentResponse`) + porta `PaymentRepository.pay()` — porta própria em vez de reaproveitar `BookingRepository`, mesmo padrão de "um port por controller" já usado (`AuthRepository`↔`AuthController`)
- [x] 18.3 `dbook_core_network`: `PaymentResponseDto`/`RegisterPaymentRequestDto` + `PaymentRepositoryImpl.pay()` (`POST /payments`)
- [x] 18.4 `SeatSelectionPage`: parou de se auto-navegar pra `BookingSuccessPage` no `ref.listen` — trocou `nextLegLabel`/`onNextLeg` (só faziam sentido com uma tela por trecho) por um único callback `onBooked(booking, flight, seat)`; quem decide o que acontece depois é sempre quem a montou
- [x] 18.5 `main.dart`: `_buildSeatSelectionFor` acumula `List<BookedLeg>` (voo+assento+booking de cada trecho já reservado); no `onBooked`, se sobra trecho, encadeia **silenciosamente** (`pushReplacement` direto, sem tela intermediária) pra seleção de assento do próximo; no último, vai pra `PaymentPage` com todos os trechos acumulados
- [x] 18.6 `PaymentPage` (nova, `dbook_feature_booking`): Resumo do Pedido (uma linha por trecho — rota + assento como detalhe + preço real — e o Total), formulário de cartão (nome, número, validade, CVV, só validação de formato — sem gateway real por trás) e botão "Pay $total"; deriva `cardLast4` dos 4 últimos dígitos digitados e nunca envia o número completo. `PaymentNotifier`/`PaymentState` (idle/submitting/error/paid) no mesmo formato de `SeatSelectionNotifier`/`SeatSelectionState`
- [x] 18.7 `PaymentSuccessPage` (nova) substitui `BookingSuccessPage` (removida, junto com seu teste) — reusa `DbookSuccessScreen`, mostra "Payment Confirmed!", a lista de trechos pagos (rota + assento) e o total, botão único "View My Bookings"
- [x] 18.8 Testes: `seat_selection_page_test.dart` (chama `onBooked` em vez de navegar sozinha), `payment_notifier_test.dart` (idle→submitting→paid/erro, envia só `cardLast4`/`cardholderName`, invalida Minhas Viagens), `payment_page_test.dart` (mostra os trechos certos e o total certo, sem taxa/checkbox fictícios, valida cartão, envia só o necessário), `payment_success_page_test.dart` (mostra os trechos pagos e o total)
- [x] 18.9 `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace

Addendum (2026-09-15) — feedback do usuário testando o app: "o detalhe
poderia ser mais rico... imagem de fundo... ícone da companhia aérea...
placeholder de cartão de crédito para testes".

- [x] 18.10 `FlightDetailPage` (`dbook_feature_flights`) ganhou cabeçalho em foto cheia do destino de chegada — cruza `flight.destinationIataCode` com a mesma lista já carregada por `featuredDestinationsProvider` (sem fetch novo, mesmo padrão do `_DestinationThumbnail` de `MyBookingsPage`), com degradê + cidade/país/data sobrepostos; sem foto no catálogo, cai num degradê pela cor da companhia em vez de deixar vazio. Virou `ConsumerWidget` pra isso
- [x] 18.11 Card do detalhe ganhou uma linha com o selo da companhia (código IATA sobre a cor fixa dela, mesmo visual do badge de `DbookFlightResultTile`) + nome da companhia + número do voo, e uma linha nova "Aircraft" (`flight.aircraftType`, dado real já existente na entidade, não mostrado antes nesta tela)
- [x] 18.12 Lógica de cor-por-companhia (`_airlineColor`/`_knownAirlineColors`/`_airlinePalette`), até então privada e duplicada dentro do próprio arquivo de resultados, extraída pra `airline_colors.dart` (pública dentro da feature, não exportada no barrel) — compartilhada entre `flight_results_page.dart` e `flight_detail_page.dart` sem duplicar
- [x] 18.13 `PaymentPage`: os 4 campos do cartão ganharam `hintText` com um número/nome de teste (`4242 4242 4242 4242`, `Jane Doe`, `12/29`, `123`) — não é dado fabricado nem promessa de cobrança real (não há gateway por trás, o número nunca é enviado inteiro), só uma conveniência pra quem for testar o fluxo
- [x] 18.14 Testes: `flight_detail_page_test.dart` reescrito com `ProviderScope`/`_FakeDestinationRepository` (a página virou `ConsumerWidget`) — cobre foto real exibida quando o destino está no catálogo, fallback sem foto quando não está, e os campos novos (companhia, aeronave)
- [x] 18.15 `melos exec -- flutter analyze` + `melos run test` limpos em todo o workspace; testado manualmente no Browser pane — detalhe do voo mostra a foto real do Rio de Janeiro (Cristo Redentor) e de São Paulo (ponte estaiada) conforme o destino, badge "UA"/"United Airlines" real, e o placeholder do cartão aparece ao focar o campo

**Checklist de fechamento do M18:**
- [x] Itens 18.1-18.9 revisados
- [x] Clean Code
- [x] Arquitetura (a reserva continua sendo criada — e o assento reservado — no momento da escolha do assento, não no pagamento, evitando uma corrida onde o assento seria perdido enquanto o usuário ainda preenche o cartão; pagar só confirma reservas já existentes; mesmo fluxo pra One Way e Round Trip, sem bifurcação de código — `_buildSeatSelectionFor` já era genérica pra 1 ou N voos)
- [x] `melos exec -- flutter analyze` + `melos run test` + `dart test` limpos em todo o workspace
- [x] Testado ponta a ponta no Browser pane (Round Trip): busca → escolhe voo de ida (GRU→GIG, LATAM Embraer E195, $366) → direto pros resultados da volta (sem assento ainda) → escolhe voo de volta (GIG→GRU, American A320, $1.632) → seleção de assento da ida (layout 2+2 real) → confirma assento 5C → SEM tela de sucesso intermediária, direto pra seleção de assento da volta (layout 3+3 real) → confirma assento 2B → cai direto em "Review & Pay" mostrando as DUAS linhas ("GRU → GIG · Seat 5C" $366,00 / "GIG → GRU · Seat 2B" $1.632,00) e o Total certo ($1.998,00, soma real, sem taxa fictícia); também validado via `curl` direto contra o backend rodando de verdade (Postgres real, não fake): registrar → logar → buscar → reservar 2 trechos → `POST /payments` com os dois `bookingIds` → resposta `amount: 2756.00` (soma exata dos dois preços) e `status: CONFIRMED` → `GET /bookings` confirma as duas reservas como `CONFIRMED`
- [x] README atualizado
- [x] Cobertura mínima — combinado: **82.01%** (2881/3513 linhas), acima do mínimo de 80% do gate de CI

## Ideias futuras (fora da numeração)

- Golden tests (regressão visual) pros componentes do `dbook_design_system`
- Deploy interno via Firebase App Distribution / TestFlight beta
