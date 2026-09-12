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
- [x] 9.2 Ação fixa no rodapé (`Scaffold.bottomNavigationBar`) em `FlightSearchPage`, `FlightDetailPage` (preço + botão juntos, como na tela 06 do kit) e no resumo de `SeatSelectionPage` (extraído pra `_SeatSelectionFooter`) — troca de botão solto no fim da `Column`, sem quebrar nenhum teste existente
- [x] 9.3 Shell do app: `IndexedStack` de 4 abas (Home/Explore/Trips/Profile, sempre visíveis) + `NavigationBar`, usando `navigationBarTheme` (temado desde o M1, nunca consumido); Drawer (`drawerTheme`, idem) acessível pela Home com "Ask DBook AI" e Sair/Entrar — App bar de `FlightSearchPage` perdeu os ícones soltos (myBookings/aiSuggestions/logout), tudo migrou pro Drawer ou virou aba própria; Trips/Profile mostram `DbookStatusPlaceholder` + CTA "Entrar" pra visitante em vez de exigir login pra ver a aba — testado em `widget_test.dart` (16 casos)
- [x] 9.4 Home ganha "Destinos em destaque" (grade de 2 colunas, `DestinationCard` — foto em cima, nome/país embaixo) acima do card de busca; tocar preenche o destino da busca direto
- [x] 9.5 Aba Explore — mesma grade dos 3 aeroportos conhecidos; tocar seta um provider efêmero (`prefillDestinationProvider`, `Notifier` — `StateProvider` não existe mais no Riverpod 3.x deste projeto) que a Home consome via `ref.listen` (não `initState`: a Home fica montada o tempo todo no `IndexedStack`, então só `ref.listen` continua reagindo depois do primeiro build) e volta pra aba Home com o destino pré-preenchido
- [x] 9.4/9.5 fotos reais — 3 fotos Unsplash (São Paulo/GRU, Rio/GIG, New York/JFK) confirmadas com o usuário antes de usar, mesmo processo do M1; carregadas via URL direta do CDN (`KnownAirport.photoUrl` + `NetworkImage`, sem asset bundled — pedido explícito do usuário), com fallback pro degradê quando `photoUrl` é nulo. Créditos em `packages/dbook_feature_flights/docs/destination_photo_credits.md`
- [x] Revisão visual adicional (fora da numeração, pedida pelo usuário depois de comparar com um app de referência gerado no Figma Make): reaproveitadas só as partes compatíveis com o backend — header hero azul com logo/tagline na Home, linha pontilhada + ícone de avião conectando horários no card de resultado (`DbookFlightResultTile`) e no detalhe do voo, header em bloco azul no Profile. Ficaram de fora abas Fly/Sleep/Eat, tipo de viagem (round/one-way/multi-city), banner de ofertas, preço nos cards de destino, "Explore by Region", filtro/seletor de dia nos resultados, taxa de bagagem, stats e menu fake do Profile — nenhum tem endpoint no backend
- [ ] 9.6 Review Order — novo, entre seleção de assento e confirmação; resumo real, **sem campo de pagamento** (não existe endpoint de pagamento no backend), confirma e chama `POST /bookings` de verdade
- [x] 9.7 (parcial) Profile — e-mail capturado no login/registro (`AuthState.loggedIn.email`, só sessão — sem `GET /users/me`, fica `null` se a sessão veio do bootstrap); `/trips/{id}` (detalhe de uma reserva) ainda não construído
- [ ] 9.8 Polimento client-side: ordenar/filtrar resultado já buscado (sem parâmetro novo na API) e banner de offline (`connectivity_plus` + `DbookInlineStatusBanner`, já existe)

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

## Ideias futuras (fora da numeração)

- Golden tests (regressão visual) pros componentes do `dbook_design_system`
- Deploy interno via Firebase App Distribution / TestFlight beta
