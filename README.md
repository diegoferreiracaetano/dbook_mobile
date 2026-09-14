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
  dbook_feature_realtime/       # disponibilidade ao vivo — cliente STOMP mínimo sobre WebSocket
  dbook_feature_ai/             # sugestão de voo por IA — busca em linguagem natural (Riverpod)
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

`dbook_domain`/`dbook_core_network` (entidades/DTOs) e `dbook_feature_auth`/`dbook_feature_flights`/`dbook_feature_booking`/`dbook_feature_realtime`/`dbook_feature_ai` (estado, via `freezed` puro sem `json_serializable`) usam codegen; depois de mexer nesses arquivos, rodar `dart run build_runner build --delete-conflicting-outputs` dentro do pacote — os `.freezed.dart`/`.g.dart` ficam versionados (sem passo de codegen no CI).

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

## CI/CD

`.github/workflows/ci.yml` roda em todo push/PR pra `main`:

- **`analyze-format-test`** — `melos run analyze` + `format` + `coverage`/`coverage:dart`, gate de cobertura mínima 80% (`very_good_coverage`). Esse é o check que o branch protection do GitHub exige antes de mergear.
- **`build-android`** — builda um APK debug (sempre) e um APK release. O release é assinado com o keystore de verdade se os secrets `ANDROID_KEYSTORE_BASE64`/`ANDROID_KEYSTORE_PASSWORD`/`ANDROID_KEY_ALIAS`/`ANDROID_KEY_PASSWORD` existirem no repo; sem eles, cai pra assinatura de debug (nunca quebra o build).
- **`build-ios`** — `flutter build ios --release --no-codesign` num runner `macos-latest`. Sem certificado/perfil de provisionamento da Apple Developer Program configurado, só valida que o app compila e arquiva — não gera um `.ipa` assinado de verdade.

### Assinatura de release (Android)

`apps/dbook_mobile/android/app/build.gradle.kts` lê `android/key.properties` (nunca commitado — já está no `.gitignore` do template do Flutter) se existir; senão, o release cai pra assinatura de debug. Pra assinar de verdade:

**Local:** copie `android/key.properties.example` pra `android/key.properties`, gere um keystore com `keytool -genkeypair` e preencha as senhas.

**CI:** cadastre os 4 secrets no repo (`gh secret set ANDROID_KEYSTORE_BASE64 < keystore.jks.base64`, etc., ou pela UI do GitHub em Settings → Secrets and variables → Actions).

## Progresso

Ver [CHECKLIST.md](CHECKLIST.md) para o detalhamento marco a marco.

- **M1 — Setup do monorepo + design system**: completo. `dbook_design_system` cobre tokens (cor/tipografia/espaçamento/raio/elevação/motion), tema claro/escuro, e todo o inventário de componentes extraído do UI kit de referência (ação, formulário, exibição de dados, navegação, feedback, overlays), com widget test em cada um. `apps/dbook_mobile` existe e consome o tema; a tela inicial é um onboarding de 3 slides (com fotos reais e ilustração no splash nativo) até o fluxo de auth (M2/M3) ser construído.
- **M2 — Domínio + rede**: completo. `dbook_domain` (entidades, portas, casos de uso) tem os campos batendo com o backend de verdade (survey do código-fonte, não suposição). `dbook_core_network` implementa as portas com Dio + DTOs (`freezed`/`json_serializable`) + mapeamento + exceptions por status HTTP. `dbook_core_storage` guarda o par de tokens no Keychain/EncryptedSharedPreferences.
- **M3 — Autenticação**: completo. `dbook_feature_auth` tem `LoginPage`/`RegisterPage` (montadas só com componentes do `dbook_design_system`), `AuthNotifier` (Riverpod) orquestrando loggedOut/loading/loggedIn/error e `PersistingAuthRepository` salvando o par de tokens a cada login/refresh. `apps/dbook_mobile` liga tudo: `_AppRoot` faz o bootstrap de sessão na abertura do app (token salvo → pula pra tela logada; senão → onboarding → login/cadastro).
- **M4 — Busca e listagem de voos**: completo. `dbook_core_session` (novo, extraído de `dbook_feature_auth`) centraliza o `Dio` autenticado — `DbookAuthInterceptor` anexa o access token em toda requisição e faz refresh automático no 401, com deduplicação de refresh concorrente, já que o refresh token do backend é de uso único; toda feature autenticada (auth e voos) compartilha essa mesma instância, o que é necessário pra deduplicação valer entre features, não só dentro de uma. `dbook_feature_flights` tem `FlightSearchPage` (seletor de aeroporto conhecido, já que o backend não expõe `/airports`), `FlightResultsPage` e `FlightDetailPage`, navegação via `go_router` embutido num `Router` próprio (sem precisar de um segundo `MaterialApp`). `apps/dbook_mobile` troca o placeholder de tela logada pela feature de voos de verdade, passando o botão de logout como ação da app bar.
- **M5 — Reserva**: completo. `dbook_feature_booking` tem `SeatSelectionPage` (mapa de assentos + confirmação antes de reservar de verdade), `BookingSuccessPage` e `MyBookingsPage`. O backend não expõe uma listagem de reservas (só criar/cancelar), então "minhas reservas" existe só em memória, populada pelas reservas feitas na sessão atual — não é um histórico persistente. `apps/dbook_mobile` liga o botão "Book This Flight" do detalhe do voo e o ícone de reservas na busca, do mesmo jeito que o M4 ligou o logout: via callback injetado, já que features não importam features entre si.
- **M6 — Tempo real**: completo. `dbook_feature_realtime` tem um cliente STOMP mínimo sobre `web_socket_channel` — conecta em `/ws`, autentica com um header STOMP nativo (`Authorization: Bearer <token>` no CONNECT, já que o handshake do WebSocket em si não aceita header HTTP custom), assina `/topic/bookables/{id}/availability` e reconecta com backoff se a conexão cair (o broker é em memória, sem fila/replay, então uma atualização perdida durante a queda é só perdida mesmo). `DbookLiveAvailability` mostra isso na tela de detalhe do voo, injetado do mesmo jeito que o botão de reservar (M5) e o logout (M4) — a feature de voos não conhece nenhuma das outras.
- **M7 — Sugestão por IA**: completo. `dbook_feature_ai` tem `AiSuggestionPage` com um `DbookSearchField` (M1, já pensado pra esse uso) pra busca em linguagem natural. `POST /ai/suggestions` só devolve `{flightId, reason}` — sem os dados do voo e sem `GET /flights/{id}` pra completar depois — então a lista mostra exatamente isso, sem fingir ter uma busca de voo por trás. Erros de rate limit (429) e modelo indisponível (502/503) usam o mesmo `DbookNetworkException.message` de toda outra feature.
- **M8 — CI/CD**: completo. Ver seção [CI/CD](#cicd) acima. Build de APK debug/release (assinado se os secrets existirem) e build de iOS sem codesign, todos verificados localmente antes de subir pro pipeline. O gate de qualidade (`analyze-format-test`) já roda desde o M1; falta só ativar o branch protection no GitHub exigindo esse check (não é algo que dá pra fazer sem autenticação `gh` de verdade no ambiente onde isso foi construído).
- **M9 — Remediação de navegação e UX**: em andamento. Auth Gate real (busca/resultado/detalhe públicos, sem exigir login pra ver preço — bate com o próprio backend, que já expõe isso como `permitAll()`), shell de 4 abas (`IndexedStack` + `NavigationBar`), "Destinos em destaque" com foto real, preço real (via M12 do backend) e favorito local (`shared_preferences`), tipo de viagem (Round Trip/One Way/Multi-city implementados, rádios temporariamente desativados na UI por pedido do usuário). Faltam: Review Order antes da confirmação (9.6) e polimento client-side (9.8).
- **M10 — Tela de Resultados da Busca (redesign)**: completo. `FlightResultsPage` ganhou cabeçalho com rota+data+botão Filter, faixa horizontal de datas com preço real por dia (`GET /flights/search` por data, sem endpoint novo), contagem de voos + selo "Best prices today" (só quando o dia é de fato o mais barato da faixa), e `DbookFlightResultTile` com selo colorido por companhia (dado real do M11 do backend, cor fixa por companhia conhecida). Ordenar por preço/duração e filtrar por classe de cabine, tudo client-side sobre o resultado já buscado.
- **M11 — `Destination` substitui `KnownAirport` (front burro)**: completo. Antes, `knownAirports` era uma lista fixa de 3 aeroportos hardcoded no Flutter — dado de negócio vivendo no front. Agora `dbook_domain` tem a entidade `Destination` (iataCode, city, country, photoUrl, lowestPrice) e a porta `DestinationRepository`, alimentadas por `GET /destinations` (M13 do backend `dbook`) — um endpoint só, sem BFF separado, moldado pro que a Home precisa: aeroporto + foto real + menor preço real numa resposta. O front não sabe mais "quais destinos existem"; só renderiza os 8 que a API manda (São Paulo, Rio, Nova York e 5 hubs internacionais novos — Londres, Paris, Lisboa, Miami, Buenos Aires). `FlightRepository.getLowestPrice` foi removido (a responsabilidade de preço por destino é só da `DestinationRepository` agora); busca, seletor de origem/destino, grade da Home e aba Explore usam todos o mesmo `featuredDestinationsProvider`.
- **M12 — "Principais destinos" e "Destinos por região" (Explore + Home)**: completo. Home e Explore filtram `destination.isPopular` (curadoria real do backend, M14 do `dbook`) pra "Destinos em destaque"/"Principais destinos". Pra região, as duas telas divergem por design: a Explore tem um filtro de verdade (`DestinationsByRegion` — chips de seleção única acima de uma grade que mostra só a região escolhida); a Home tem um carrossel de navegação (`RegionCarousel` — 1 card por região, foto real + nome, sem filtrar nada na própria tela). Tocar um card do carrossel leva pra Explore já com aquela região selecionada (`prefillRegionProvider`, mesma "ponte efêmera" de `prefillDestinationProvider`, só que no sentido contrário). Uma chamada só (`GET /destinations`, sem mudança de endpoint) — tudo vem da mesma lista já carregada por `featuredDestinationsProvider`. `DbookChipRow` (faixa de chips, mesmo padrão visual do `DbookFareDateStrip`) entrou no design system antes da feature usar.
- **M13 — Perfil real**: completo. `User` ganha `name` de verdade (via `GET /users/me`/`PATCH /users/me` do M15 do backend `dbook`) — o app deixou de reaproveitar só o que o formulário de login/registro digitou e passou a buscar o perfil real do servidor logo após login/registro/bootstrap (`AuthNotifier._syncProfile`), também corrigindo o e-mail não sobrevivendo a um reload. `ProfilePage` (extraída de `main.dart`) mostra avatar com iniciais, nome e e-mail reais, e um "Editar Perfil" funcional (`PATCH /users/me`) — deliberadamente sem os itens decorativos (Travel Documents, Payment Methods etc.) da referência visual, já que nenhum deles tem tela ou dado real por trás.
- **M14 — Assento por modelo de avião real**: completo. A seleção de assento era um grid fixo de 6 colunas, igual pra qualquer voo. Agora `Flight` carrega `aircraftType`/`seatLayout` reais (do M16 do backend `dbook`) e `SeatSelectionPage` agrupa os assentos por fileira e por bloco de colunas do `seatLayout` — um Embraer E195 mostra 2+2 com 1 corredor, um Boeing 777 mostra 3+4+3 com 2 corredores, tudo vindo do array que o backend já resolve (o app nunca decide sozinho qual avião mapeia pra qual layout). `DbookSeatCell` ganhou um formato mais parecido com uma poltrona (topo arredondado) e o label do assento visível.
- Em andamento — M9 (parcial); M10, M11, M12, M13 e M14 completos.
