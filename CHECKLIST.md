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

## M3 — Autenticação ⬜

- [x] 3.1 Criar o pacote `packages/dbook_feature_auth`
- [x] 3.2 Tela de registro (formulário + validação) — `RegisterPage`
- [x] 3.3 Tela de login (formulário + validação) — `LoginPage`
- [x] 3.4 Riverpod: `AuthNotifier` (estados loggedOut/loading/loggedIn/error)
- [x] 3.5 Implementação real do `AuthRepository` (usa `dbook_core_network`, salva tokens no `dbook_core_storage`) — `PersistingAuthRepository` decora o `AuthRepositoryImpl` de rede
- [x] 3.6 Interceptor Dio: anexa o access token em toda requisição autenticada — `DbookAuthInterceptor.onRequest`
- [x] 3.7 Interceptor Dio: detecta 401, faz refresh automático, repete a requisição original — `DbookAuthInterceptor.onError`, com deduplicação de refresh concorrente (`_refreshing`)
- [ ] 3.8 Bootstrap de sessão: app abre e checa token válido salvo, pula direto pra tela logada
- [ ] 3.9 Logout: limpa o secure storage, volta ao estado loggedOut

**Checklist de fechamento do M3:**
- [ ] Itens 3.1-3.9 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M4 — Busca e listagem de voos ⬜

- [ ] 4.1 Criar o pacote `packages/dbook_feature_flights`
- [ ] 4.2 Tela de busca (origem/destino/data)
- [ ] 4.3 Implementação real do `FlightRepository`
- [ ] 4.4 Riverpod: `FlightSearchNotifier` (estados idle/loading/success/error)
- [ ] 4.5 Lista de resultados (item de voo usando o `dbook_design_system`)
- [ ] 4.6 Tela de detalhe do voo (navegação via `go_router`)

**Checklist de fechamento do M4:**
- [ ] Itens 4.1-4.6 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M5 — Reserva ⬜

- [ ] 5.1 Criar o pacote `packages/dbook_feature_booking`
- [ ] 5.2 Implementação real do `BookingRepository`
- [ ] 5.3 Ação de reservar a partir da tela de detalhe (botão + confirmação)
- [ ] 5.4 Riverpod: `BookingNotifier`
- [ ] 5.5 Tela "minhas reservas" (lista com status PENDING/CONFIRMED/CANCELLED)
- [ ] 5.6 Ação de cancelar reserva
- [ ] 5.7 Tratamento de erro específico: 409 (sem disponibilidade), 403 (não é dono), 404

**Checklist de fechamento do M5:**
- [ ] Itens 5.1-5.7 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M6 — Tempo real ⬜

Decisão: mesmo padrão do M5 do backend — WebSocket/STOMP, não polling. Client em Dart via `web_socket_channel` (STOMP é só um protocolo de frame em cima de WebSocket puro, não precisa de biblioteca STOMP-específica pra um caso de uso tão focado).

- [ ] 6.1 Criar o pacote `packages/dbook_feature_realtime`
- [ ] 6.2 Cliente STOMP mínimo sobre `web_socket_channel` (frame CONNECT com header Authorization)
- [ ] 6.3 Assinatura por tópico (`/topic/bookables/{id}/availability`)
- [ ] 6.4 Parse do frame MESSAGE recebido
- [ ] 6.5 Integração na tela de detalhe do voo: assina ao entrar, cancela a assinatura ao sair, atualiza disponibilidade ao vivo
- [ ] 6.6 Tratamento de desconexão/reconexão do WebSocket

**Checklist de fechamento do M6:**
- [ ] Itens 6.1-6.6 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M7 — Sugestão por IA ⬜

- [ ] 7.1 Criar o pacote `packages/dbook_feature_ai`
- [ ] 7.2 Campo de busca em linguagem natural
- [ ] 7.3 Implementação real do `AiSuggestionRepository`
- [ ] 7.4 Riverpod: `AiSuggestionNotifier`
- [ ] 7.5 Lista de sugestões (voo + motivo, usando o `dbook_design_system`)
- [ ] 7.6 Tratamento de erro específico: 429 (rate limit), 502/503 (modelo indisponível)

**Checklist de fechamento do M7:**
- [ ] Itens 7.1-7.6 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M8 — CI/CD ⬜

Decisão: só entra depois que o app já builda e roda de ponta a ponta manualmente — mesmo princípio do M8 do backend ("só automatiza depois que já validou na mão").

- [ ] 8.1 Build de APK debug automatizado no pipeline (a cada push)
- [ ] 8.2 Build de APK release assinado (keystore via secret do GitHub)
- [ ] 8.3 Build de IPA no pipeline — se houver Mac runner disponível
- [ ] 8.4 Gate de qualidade completo bloqueando merge (`analyze` + `format` + `test` + cobertura mínima)

**Checklist de fechamento do M8:**
- [ ] Itens 8.1-8.4 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## Ideias futuras (fora da numeração)

- Golden tests (regressão visual) pros componentes do `dbook_design_system`
- Deploy interno via Firebase App Distribution / TestFlight beta
