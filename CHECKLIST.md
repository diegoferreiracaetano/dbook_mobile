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
8. Testes adicionados pras camadas ainda não cobertas (unit nos casos de uso/repositórios, widget test nas telas principais).
9. README.md atualizado com o que foi feito no marco.
10. Cobertura de teste (`very_good_coverage` sobre o `lcov.info` combinado) acima do mínimo combinado.

## M1 — Setup do monorepo + design system ⬜

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
- [ ] 1.11 Botão (primary/secondary/text; estados default/disabled/loading)
- [ ] 1.12 Botão de ícone circular e botão de destaque circular (ex.: sino, voltar, trocar origem/destino)
- [ ] 1.13 Segmented control / toggle (ex.: ida × ida-e-volta)

*Formulário:*
- [ ] 1.14 Campo de texto outlined (estados default/foco/erro/disabled; ícone à esquerda; ícone à direita ex. mostrar senha)
- [ ] 1.15 Campo de busca (ícone + placeholder) e seletor de data / intervalo de datas
- [ ] 1.16 Legenda de seleção (swatch + rótulo, ex. livre/selecionado/ocupado no mapa de assento)

*Exibição de dados:*
- [ ] 1.17 Card base (elevado/tonal) e item de lista genérico (ícone/imagem + título + subtítulo + seta) — fundação dos itens abaixo
- [ ] 1.18 Avatar (foto/inicial, tamanhos), Chip neutro, Badge de status semântico (confirmada/pendente/cancelada, cor por estado)
- [ ] 1.19 Card de destino (foto + degradê + título/subtítulo sobrepostos) e linha de resultado de voo (horário, duração, preço, estado selecionado)
- [ ] 1.20 Célula de mapa de assento (3 estados) e bloco de código QR/barcode
- [ ] 1.21 Estilo de preço em destaque (tipografia grande, reusada em Detalhe do voo / Revisar reserva / Bilhete)

*Navegação e estrutura:*
- [ ] 1.22 App bar (variantes: cor sólida, transparente sobre imagem, com botão voltar, com subtítulo)
- [ ] 1.23 Barra de navegação inferior (com indicador "pill" no item ativo) e Drawer de navegação
- [ ] 1.24 Rótulo de seção (texto pequeno + ícone, ex. "SUGESTÕES PRA VOCÊ") e Divisor (sólido e tracejado)

*Feedback:*
- [ ] 1.25 Indicador de carregamento, estado vazio, estado de erro (padrão reusado em toda tela que busca dado)
- [ ] 1.26 Estado de sucesso (ícone grande em círculo) e faixa de status inline (ex. "Disponibilidade em tempo real")

*Overlays:*
- [ ] 1.27 Bottom sheet e dialog de confirmação
- [ ] 1.28 Indicador de página / dots (usado no onboarding)

**Documentação viva dos componentes:**
- [ ] 1.29 Catálogo visual (ex.: [Widgetbook](https://pub.dev/packages/widgetbook)) mostrando cada componente/estado isolado, pra QA visual sem precisar rodar o app inteiro

**App raiz + CI:**
- [ ] 1.30 Criar o app Flutter raiz em `apps/dbook_mobile/`, consumindo o tema do `dbook_design_system` via dependência `path:`
- [ ] 1.31 CI (GitHub Actions): `melos bootstrap` + `melos run analyze` + `dart format --set-exit-if-changed .`
- [ ] 1.32 CI: adicionar `melos run test` ao workflow

**Checklist de fechamento do M1:**
- [ ] Itens 1.1-1.32 revisados
- [ ] Nenhum valor de cor/espaçamento/fonte hardcoded fora do `dbook_design_system` (grep rápido por hex codes soltos nas features)
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M2 — Domínio + rede ⬜

Decisão: `dbook_domain` é Dart puro, zero dependência de Flutter/Riverpod — mesmo princípio de Clean Architecture do backend. Serialização via `freezed` + `json_serializable` (padrão de mercado pra imutabilidade + codegen de JSON em Dart).

- [ ] 2.1 Criar o pacote `packages/dbook_domain` (Dart puro, sem dependência de Flutter)
- [ ] 2.2 dbook_domain: entidade `Flight`
- [ ] 2.3 dbook_domain: entidade `Airport`
- [ ] 2.4 dbook_domain: entidade `Booking` (+ enum de status)
- [ ] 2.5 dbook_domain: entidade `User`
- [ ] 2.6 dbook_domain: entidade `AiSuggestion`
- [ ] 2.7 dbook_domain: portas (interfaces) — `FlightRepository`, `BookingRepository`, `AuthRepository`, `AiSuggestionRepository`
- [ ] 2.8 dbook_domain: casos de uso (`SearchFlightsUseCase`, `RegisterBookingUseCase`, `CancelBookingUseCase`, etc.)
- [ ] 2.9 Criar o pacote `packages/dbook_core_network`, configurar Dio (base URL, timeouts, logging em debug)
- [ ] 2.10 dbook_core_network: DTOs com `freezed` + `json_serializable` (build_runner)
- [ ] 2.11 dbook_core_network: mapeamento DTO → entidade de domínio
- [ ] 2.12 dbook_core_network: exceptions de rede mapeadas a partir do status HTTP da API
- [ ] 2.13 Criar o pacote `packages/dbook_core_storage` (`flutter_secure_storage`), wrapper pra salvar/ler o par de tokens

**Checklist de fechamento do M2:**
- [ ] Itens 2.1-2.13 revisados
- [ ] Clean Code
- [ ] Arquitetura
- [ ] Componentização (tela usa só componentes do `dbook_design_system`, zero widget customizado solto)
- [ ] Layout (espaçamento e montagem da tela seguem os padrões do `dbook_design_system`, nada de número solto ou arranjo remontado à mão)
- [ ] Material Design (componentes são temas em cima de widgets Material 3 do Flutter, não reconstruídos do zero)
- [ ] `analyze` + `format` + `test` limpos
- [ ] Testes das camadas ainda sem cobertura
- [ ] README atualizado
- [ ] Cobertura mínima

## M3 — Autenticação ⬜

- [ ] 3.1 Criar o pacote `packages/dbook_feature_auth`
- [ ] 3.2 Tela de registro (formulário + validação)
- [ ] 3.3 Tela de login (formulário + validação)
- [ ] 3.4 Riverpod: `AuthNotifier` (estados loggedOut/loading/loggedIn/error)
- [ ] 3.5 Implementação real do `AuthRepository` (usa `dbook_core_network`, salva tokens no `dbook_core_storage`)
- [ ] 3.6 Interceptor Dio: anexa o access token em toda requisição autenticada
- [ ] 3.7 Interceptor Dio: detecta 401, faz refresh automático, repete a requisição original
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
