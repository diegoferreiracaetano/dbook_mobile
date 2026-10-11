# Portal administrativo (`apps/dbook_admin`)

Flutter Web, URL por caminho, falando com `/v1/admin/**` do backend. O servidor
é a autoridade (front burro): o menu e os botões saem das permissões de
`GET /v1/admin/auth/me`, mas quem autoriza é o servidor.

## Pacotes

| Pacote | Papel |
|---|---|
| `dbook_admin_data` | Dart puro. Modelos de leitura tolerantes (`JsonRead`: campo ausente ou de tipo errado não derruba a tela) e APIs (`abstract interface class` + `DioXxxApi`); todo erro passa por `guarded()` e vira `DbookNetworkException` com `code` |
| `dbook_admin_session` | Token só em memória, renovação em voo único, interceptor, estados da sessão, ociosidade, rascunhos, `PermissionGate`, download e seletor de arquivo |
| `dbook_admin_l10n` | `app_pt.arb`, formatos, mensagens de erro por `code` |
| `dbook_feature_admin_{auth,team,customers,bookings,catalog,dashboard,governance}` | Telas e estado de cada área |
| `apps/dbook_admin` | Composição: rotas, shell responsivo, faixa de ambiente, saúde da API, fronteira de erro |

## Rotas

`/login`, `/accept-invite`, `/change-password`, e dentro do shell: `/`,
`/account`, `/account/password`, `/forbidden`, `/team`, `/customers[/:id]`,
`/bookings[/:id]`, `/refunds`, `/flights[/new|/import|/:id]`, `/airlines`,
`/airports`, `/dashboard` (importação adiada), `/audit`, `/reviews`,
`/promos`. Filtros, ordem e página vão na query string (link direto e recarga
preservam).

## Configuração

`--dart-define=API_BASE_URL=...` (padrão `http://localhost:8080/v1`),
`APP_ENV` (`local`, `staging`, `production`; fora de produção aparece uma
faixa) e `APP_VERSION`.

## Decisões que valem lembrar

- O backend **não** manda `mustChangePassword`; o modelo lê o campo se ele
  passar a existir, sem mudar o app.
- Modelos escritos à mão, sem freezed/json_serializable: o portal só lê, e a
  leitura tolerante é intencional.
- Listas usam *records* como chave de `FutureProvider.autoDispose.family` e um
  codec entre a consulta e a query string.
- Mutações invalidam os providers afetados; operações financeiras levam
  `Idempotency-Key` por tentativa (mesma chave se a resposta se perdeu, chave
  nova depois de uma falha).
- Só 401/403 de **renovação recusada** encerra a sessão; erro de rede mantém.

## Verificado e não verificado

Verificado (atualizado em 2026-10-10): `flutter analyze` limpo em todos os
pacotes; testes unitários e de widget de todos os pacotes do portal, inclusive
os de **contrato com respostas reais da API** e as páginas renderizadas com
elas; build web de produção e tamanho do bundle (1164 KB gz contra orçamento
de 1500); e o portal **renderizado no navegador contra o backend real**
(login, menu por permissão, clientes, dashboard, reservas). Cobertura
combinada do repositório: 80,68 %.

Corrigido pelos testes: dropdowns do formulário de voo estouravam à direita,
o selo de status estourava em coluna estreita, as linhas de tabela com duas
linhas de texto estouravam a altura, e a fila de moderação ganhou um menu de
ações (o botão "Dispensar denúncias" não recebia clique).

**Ainda não executado:** o E2E (`integration_test/portal_flows_test.dart`
está escrito e roda no workflow `e2e-portal.yml`; localmente falta o
`chromedriver`), Lighthouse e o deploy (`deploy-portal.yml`, com portão de
credencial AWS: o projeto não será publicado). **Fora do portal por enquanto:**
a tela de hotéis (a API `/v1/admin/accommodations` já existe) e a
pré-visualização da foto no formulário de aeroportos.
