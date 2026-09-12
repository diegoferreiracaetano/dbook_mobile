# Dbook Mobile — Especificação de Navegação e Plano de Remediação (M9)

## Sumário executivo

O app funciona (arquitetura Clean, cobertura de teste, tratamento de erro
por status HTTP — tudo isso passa QA técnico). **Não passa QA de produto**:
a composição de tela nunca foi validada contra o UI kit aprovado no M1, e
o fluxo de autenticação contraria o próprio contrato da API que ele
consome. Este documento (1) audita o estado atual contra a referência,
severidade por severidade, (2) identifica a causa raiz — não só o sintoma
— e (3) especifica o Navigation Graph alvo com critério de aceite por
fase, escopo negativo explícito e registro de risco.

**Decisão de escopo**, confirmada com o usuário: construir o Navigation
Graph completo pedido (todas as rotas, inclusive as sem backend), mas
apenas as rotas com suporte real na API viram funcionalidade de verdade —
o resto vira estado "em breve" honesto, nunca uma tela que finge
funcionar. Ver seção "Matriz de capacidade do backend".

## Auditoria — estado atual vs. referência aprovada

| # | Área | Referência (UI kit, M1) | Estado atual | Severidade | Causa raiz |
|---|------|--------------------------|---------------|------------|------------|
| 1 | Fluxo de entrada | Busca/exploração livre; login só na compra | `_AppRoot` bloqueia **tudo** atrás de `AuthState.loggedIn` — onboarding leva direto pro login | **Crítica** | Decisão de arquitetura no M3 nunca foi confrontada com o contrato real da API; `GET /flights/search` e `GET /bookables/{id}/seats` são `permitAll()` no `SecurityConfig.kt` desde sempre |
| 2 | Ação primária | Botão fixo no rodapé (telas 03, 06, 07, 08) | Botão solto no fim de uma `Column` que rola (`FlightSearchPage`, `FlightDetailPage`, resumo de `SeatSelectionPage`) | **Alta** | Nenhum dos 4 checklists de fechamento (M4/M5/M6/M7) tinha um passo de comparação visual pixel-a-pixel com o kit — o item "Layout" do checklist foi verificado contra os *tokens* (espaçamento, cor), nunca contra a *composição* da tela |
| 3 | Navegação | Bottom nav (Home/Trips/Explore/Profile) + Drawer | Nenhum dos dois — ações soltas em ícone de app bar | **Alta** | `navigationBarTheme`/`drawerTheme` foram temados no M1 e nunca consumidos — ficou registrado como componente "pronto" no CHECKLIST sem nunca virar tela |
| 4 | Descoberta (Explore/Destinations) | Cards de destino com foto, grade de categorias | Não existe | **Média** | Fora do escopo de qualquer milestone M1-M8; nunca foi cobrado explicitamente até agora |
| 5 | Passenger & Extras / Payment | Telas dedicadas no kit | Não existem — fluxo pula de assento pra confirmação | **Baixa** (ver Matriz) | `POST /bookings` não aceita esses campos — não é lacuna de implementação, é ausência de contrato no backend |
| 6 | Profile | Dados pessoais, documentos, preferências | Não existe | **Média** | Mesma causa do item 4 |

**O item 1 é o único bloqueador de verdade** — é o que faz o app se
comportar diferente de qualquer app de viagem real (nenhum concorrente
exige conta pra ver preço). Os itens 2-3 são debt de composição visual,
sérios mas mecânicos de corrigir. Os itens 4-6 são escopo novo.

## Matriz de capacidade do backend

Toda decisão de "constrói de verdade" vs. "placeholder consciente" vem
desta tabela — auditada lendo o código-fonte do backend
(`SecurityConfig.kt`, `*Controller.kt`), não suposição.

| Capacidade pedida | Endpoint real | Decisão |
|---|---|---|
| Busca de voo, mapa de assento | `GET /flights/search`, `GET /bookables/{id}/seats` — públicos | ✅ Real, sem gate |
| Login/registro/refresh | `POST /auth/{register,login,refresh}` — só e-mail+senha | ✅ Real. Social login, "esqueci senha": ⬜ sem endpoint |
| Sugestão por IA | `POST /ai/suggestions` — **autenticado** (rate-limit 5/min/usuário) | ✅ Real, atrás do Auth Gate (diferente do que a auditoria inicial supôs — corrigido após checar `AiSuggestionController.kt`) |
| Criar/cancelar reserva | `POST /bookings`, `POST /bookings/{id}/cancel` | ✅ Real, atrás do Auth Gate |
| Passageiro/extras/pagamento | Nenhum campo em `POST /bookings` além de `bookableId`+`seatId` | ⬜ Não construídas — coletar e descartar viola o padrão de honestidade já aplicado em M4 (aeroportos)/M5 (minhas reservas)/M7 (sugestão IA) |
| Listar reservas/perfil | Nenhum `GET /bookings` nem `GET /users/me` | 🔶 "Minhas reservas"/"Profile" existem, mas só com dado de sessão (já é assim desde M5) |
| Destinos, ofertas, hotéis/carros | Nenhum endpoint fora de voos | Destinos: 🔶 lista estática dos 3 aeroportos conhecidos. Ofertas/hotéis/carros: ⬜ fora de escopo, não entram no Navigation Graph nem como placeholder — não é produto deste app |
| Favoritos, notificações, configurações de conta | Nenhuma persistência | ⬜ fora desta rodada |

Legenda: ✅ real e funcional · 🔶 real, mas client-side/sessão (sem
persistência de servidor) · ⬜ fora de escopo, não implementado.

## Navigation Graph alvo

```
/onboarding                    ✅ 3 slides, uma vez só (flag local via shared_preferences)

/auth/login, /auth/register    ✅ já existem
/auth/forgot-password          ⬜ fora de escopo (sem endpoint)

/search (= Home)               ✅ FlightSearchPage
/search/results                ✅ FlightResultsPage
/search/results?sort=…         🔶 ordenação client-side sobre a lista já buscada
/flight/{id}                   ✅ FlightDetailPage — ⚠️ não é deep-linkável de fora
                                   (sem GET /flights/{id}; só alcançável vindo de
                                   um resultado de busca já em memória)

/explore                       🔶 categoria única "Destinos"
/destination/{id}              🔶 3 aeroportos conhecidos, toca → pré-preenche /search

/ai (Ask DBook AI)             ✅ atrás do Auth Gate (POST /ai/suggestions exige sessão)

/booking/seats                 ✅ atrás do Auth Gate
/booking/review                ✅ novo — substitui "Payment": resumo real, sem
                                   campo de cartão, confirma → POST /bookings
/booking/success                ✅ já existe

/trips                         🔶 sessão (BookingRecord em memória), atrás do Auth Gate
/trips/{id}                    🔶 novo, mesma fonte de dado
/profile                       🔶 novo, e-mail de sessão, atrás do Auth Gate

/settings, /notifications, /favorites, /help, /deals   ⬜ fora de escopo
```

## Auth Gate

Guest navega livre em `/search/*`, `/flight/*`, `/explore`,
`/destination/*`. O gate dispara em: tocar "Select Flight", abrir "Ask
DBook AI", e abrir as abas Trips/Profile sem sessão. Em todos:

1. Captura o que precisa sobreviver ao login (o `Flight` selecionado, no
   caso da compra; nada, nos outros casos).
2. Empurra `LoginPage`/`RegisterPage` (`rootNavigator`, fora do `Router`
   interno de cada feature) via um helper único `pushAuthGate` — captura
   a rota de origem (`ModalRoute.of(context)`) antes de empurrar.
3. Ao autenticar (`onLoggedIn`/`onRegistered`, callbacks que já existem
   nas duas telas), faz `popUntil` de volta pra rota de origem e então
   `push` do destino — nunca devolve pra Home, e o back-stack fica
   coerente independente de o usuário ter ido só por Login ou também por
   Register no meio do caminho.
4. Sessão cair no meio de `/booking/*` (refresh falha) — mesmo mecanismo:
   `DbookAuthInterceptor` já limpa a sessão (M3); a UI reage abrindo o
   gate de novo no mesmo lugar.

## Fases, com critério de aceite

Cada fase fecha com o mesmo ritual de todo milestone deste projeto:
`melos run analyze`+`format`+`test` limpos, e — como isto é regressão
visual, não só funcional — comparação lado a lado no Browser pane com o
print do kit antes de marcar como pronta.

**Fase 1 — Auth Gate real**
`apps/dbook_mobile/lib/main.dart`. `_AppRoot` para de decidir "qual tela"
por `AuthState` e passa a decidir só "o quê dentro da ação". Bootstrap de
sessão deixa de bloquear o primeiro frame.
*Aceite*: visitante abre o app, busca, vê resultado e detalhe de voo sem
nenhum prompt de login; tocar "Select Flight" sem sessão abre login e,
após autenticar, cai direto no assento do voo escolhido (não na Home);
suite de teste existente (`apps/dbook_mobile/test/widget_test.dart`)
atualizada pra cobrir os dois caminhos.

**Fase 2 — Ação fixa no rodapé**
`FlightSearchPage`, `FlightDetailPage`, `SeatSelectionPage` (resumo) —
troca de botão solto em `Column` pra `Scaffold.bottomNavigationBar`.
*Aceite*: rolar o conteúdo de cada tela até o fim, botão continua visível
e clicável sem precisar rolar.

**Fase 3 — Shell: bottom nav + Drawer**
4 abas fixas (Home/Explore/Trips/Profile) sempre visíveis — Trips/Profile
mostram `DbookStatusPlaceholder` + CTA "Entrar" pra visitante em vez de
sumir da barra (mais previsível que trocar o conjunto de abas por sessão).
Drawer acessível pela Home com sugestão por IA + logout/entrar.
*Aceite*: trocar de aba preserva o estado de cada uma (busca em andamento
não reseta ao voltar pra Home); visitante consegue ver as 4 abas e é
levado ao login só ao tentar usar Trips/Profile de fato.

**Fase 4 — Home com destinos em destaque**
`DbookDestinationCard` (existe desde M1, nunca usado) acima do card de
busca.

**Fase 5 — Explore + Destinations**
Novo dentro de `dbook_feature_flights`. Fotos novas e reconhecíveis (não
as genéricas do onboarding) — confirmo com o usuário antes de baixar,
mesmo processo do M1. Tocar um destino seta um provider efêmero que
`FlightSearchPage` lê uma vez pra pré-preencher o destino.

**Fase 6 — Review Order**
Novo em `dbook_feature_booking`, entre assento e `POST /bookings`.
*Aceite*: nenhum campo de pagamento em tela; o resumo mostrado bate
exatamente com o que `POST /bookings` vai enviar.

**Fase 7 — Trips detail + Profile**
`/trips/{id}` reaproveita `BookingRecord` já em memória (sem chamada
nova). `AuthState.loggedIn` ganha `email` (capturado no login/registro,
só sessão — sem `GET /users/me`).

**Fase 8 — Polimento client-side**
Ordenação/filtro sobre resultado já buscado; banner de offline
(`connectivity_plus` + `DbookInlineStatusBanner`, já existe).

## Registro de risco

| Risco | Impacto | Mitigação |
|---|---|---|
| `IndexedStack` de 4 abas mantém 4 subtrees vivas (busca+resultados+detalhe, cada aba) — custo de memória e possível estado obsoleto (ex. resultado de busca antigo ainda montado) | Médio | Cada aba só reconstrói o que já reconstruía isolado hoje (`FlightsHomePage` já tem seu próprio `GoRouter`); nenhuma tela nova fica "presa" sem poder ser descartada — testar troca de aba repetida no Browser pane antes de fechar a Fase 3 |
| Duplicar `LoginPage`/`RegisterPage` push em vários pontos (compra, IA, Trips/Profile) diverge com o tempo | Baixo | Helper único `pushAuthGate(BuildContext, {required WidgetBuilder onAuthenticated})` em `main.dart`, usado em todo ponto — não duplicar a lógica de push/popUntil |
| Regressão nos testes de widget existentes que assumem o fluxo antigo (login obrigatório) | Alto se não pego cedo | `apps/dbook_mobile/test/widget_test.dart` é reescrito na Fase 1, não só estendido — todo teste que hoje pressupõe "só chega na Home logado" precisa mudar de premissa |
| Fotos novas de destino sem licença adequada | Baixo | Mesmo processo já usado no onboarding: buscar, confirmar licença Unsplash e a foto exata com o usuário antes de baixar |

## Fora de escopo (explícito, não esquecido)

Pagamento real (PIX/cartão/carteiras), alteração de reserva com diferença
de preço, check-in, favoritos, notificações push, configurações de conta,
central de ajuda dinâmica, hotéis/carros/experiências, "esqueci minha
senha", login social funcional, deep link pra voo/reserva específica. Cada
um depende de um endpoint que não existe no backend — construir a tela
sem o backend seria repetir exatamente o erro que motivou esta revisão.

## Estratégia de commit

Uma fase = um commit (mesmo ritmo de M3-M8): mensagem descrevendo o
comportamento antes/depois, não a lista de arquivos. Fase 1 é o commit
mais sensível (reescreve `_AppRoot` e o teste de app inteiro) — fecha e
valida sozinha antes de abrir a Fase 2.
