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

Verificado: `flutter analyze` limpo, testes unitários e de widget dos pacotes
de sessão, dados e codecs, build web de produção, tamanho do bundle
(1164 KB gz contra orçamento de 1500).

**Não** executado até aqui: backend real (o Docker não subiu na máquina),
E2E (`integration_test/portal_flows_test.dart` escrito, não rodou), Lighthouse,
deploy (`deploy-portal.yml` escrito, com portão de credencial AWS).
