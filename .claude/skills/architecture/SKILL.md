---
name: architecture
description: Decisões arquiteturais do app Flutter DBook Mobile — o que cada pacote do monorepo faz, onde colocar código novo (domínio, rede, estado, UI, design system, app), quando criar (ou não) pacote/abstração/componente, e como duas features conversam sem se importar. Use SEMPRE que a dúvida for "onde isso vai?", "preciso de um pacote/use case/provider novo?", "como uma feature aciona a outra?", "isso vira componente do design system?" ou ao planejar qualquer feature que cruze pacotes, antes de escrever código.
---

# Arquitetura — DBook Mobile

Monorepo melos/pub workspaces, em camadas por pacote. Dependência sempre para baixo; `design_system` é folha.

```
apps/dbook_mobile ──▶ dbook_feature_* ──▶ dbook_core_session ──▶ dbook_core_network ──▶ dbook_domain (Dart puro)
                            │                     └────────────▶ dbook_core_storage ──▶ dbook_domain
                            └──▶ dbook_design_system (só Flutter + google_fonts; não conhece domínio)
```
(Grafo tirado dos `pubspec.yaml` — features não dependem umas das outras: 0 violações hoje; mantenha.)

## Responsabilidade de cada pacote

| Pacote | É | Não é |
|---|---|---|
| `dbook_domain` | Entidades freezed, **portas** (`abstract interface class XxxRepository`), use cases finos. Dart puro | Lugar de Flutter, Dio, JSON |
| `dbook_core_network` | Dio, DTOs (freezed+json) ↔ domínio, `XxxRepositoryImpl`, `DbookNetworkException`, `wire_enums` | Lugar de estado/UI/Riverpod |
| `dbook_core_storage` | Guardar par de tokens (secure storage) | — |
| `dbook_core_session` | `dioProvider` autenticado (token + refresh 401), `baseUrlProvider`, `tokenStorageProvider` | Regra de feature |
| `dbook_feature_<x>` | Uma capacidade de produto: `state/` (Notifier + freezed + providers), `ui/` (páginas), barrel | Importar outra feature |
| `dbook_design_system` | Tokens, `DbookTheme`, componentes `Dbook*` reutilizáveis | Conhecer entidade de domínio ou feature |
| `apps/dbook_mobile` | **Composition root**: abas, Auth Gate, jornada de reserva, ponte entre features, override de `baseUrlProvider` | Regra de negócio que caiba numa feature |

## Onde um código novo entra (decida nesta ordem)

1. **Regra/entidade de negócio pura** → `dbook_domain` (mirror do que o backend devolve — o backend é o dono do contrato).
2. **Falar com a API** → DTO + `XxxRepositoryImpl` em `dbook_core_network`; a porta em `dbook_domain`. O domínio não sabe de JSON.
3. **Estado de uma tela/fluxo** → `Notifier` + state freezed no pacote da feature; provider do repositório também lá (`Provider<XxxRepository>((ref) => XxxRepositoryImpl(ref.watch(dioProvider)))`).
4. **Aparência reutilizável por 2+ features** → componente no `dbook_design_system` (+ export + teste + widgetbook). Uso único → widget privado `_Xxx` no arquivo da tela.
5. **Uma feature precisa de algo de outra** → **não importe**. A página recebe callback/`Widget`/parâmetro e o `main.dart` liga (ex.: `onBook`, `onBooked`, `onPaid`, `liveAvailability`).
6. **Decisão de fluxo entre telas de features diferentes** → `main.dart` (ex.: `_buildSeatSelectionFor` decide próximo assento vs. `PaymentPage`).

## Como duas features conversam (padrão do projeto)

`SeatSelectionPage` (booking) não sabe o que vem depois: só chama `onBooked(booking, flight, seat)`. `FlightDetailPage` (flights) recebe `onBook` e `liveAvailability` (um `Widget` de `dbook_feature_realtime`) por parâmetro. `MyBookingsPage` recebe `destinations` do app, que já os tem (`featuredDestinationsProvider`). Duplicar um detalhe pequeno entre features (mapa de cor por companhia em `flights` e `booking`) é **aceito** — o custo de criar dependência entre features é maior. Dentro da **mesma** feature, compartilhe (`dbook_feature_flights/lib/src/airline_colors.dart`).

## Quando criar uma abstração / pacote (e quando NÃO)

Crie quando houver **2º uso real**: componente em 2+ features → design system; helper em 2+ arquivos da mesma feature → arquivo próprio no `src/` da feature. Pacote novo `dbook_feature_<x>` só para uma capacidade de produto nova e independente (com sua barrel e pubspec seguindo os irmãos; registre no `workspace:` do `pubspec.yaml` raiz).

**Não** crie: use case "por simetria" (as features leem o repositório direto via provider — só existe use case no domínio sem consumidor; não aumente isso); camada de "service"/"manager" entre notifier e repositório; classe wrapper para um record (`typedef BookedLeg = ({Booking booking, Flight flight, Seat seat})` basta); provider/estado duplicando dado que já está em provider; pacote para um único arquivo; interface sem segunda implementação **fora** das portas do domínio.

## Decisões estruturais já tomadas (não reverta sem o dono)

- **Front burro** e **design system primeiro** (ver `CLAUDE.md`): o app não inventa dado nem promessa.
- **Riverpod à mão**, sem gerador; **freezed** para entidades/DTOs/estados; `json_serializable` só nos DTOs.
- **`Navigator` + `MaterialPageRoute`** no root para a jornada e o Auth Gate; **`go_router` só** na aba Home.
- **Erro tipado na fronteira de rede** (`DbookNetworkException` sealed) e mensagem vinda do backend.
- **Reserva cria a booking e reserva o assento na hora; pagamento só confirma**; a jornada escolhe todos os voos → todos os assentos (encadeados em silêncio) → **uma** revisão/pagamento → **uma** confirmação. Nunca mande número completo de cartão/CVV ao backend (só `cardLast4` + nome).
- **Gerados versionados** (`*.freezed.dart`/`*.g.dart`) — CI não roda codegen.

## Exemplos reais de "onde foi parar"

- *Pagamento (M18)*: `Payment`/`PaymentRepository` em `domain`; DTOs + `PaymentRepositoryImpl` em `core_network`; `PaymentNotifier`/`PaymentState`/`PaymentPage`/`PaymentSuccessPage` em `dbook_feature_booking`; o encadeamento assento→assento→pagamento em `main.dart`. `BookedLeg` (record) em `feature_booking/src/booked_leg.dart`.
- *Detalhe do voo rico*: foto do destino cruzada com `featuredDestinationsProvider` **dentro** de `dbook_feature_flights` (mesmo pacote que define o provider — sem cruzar feature); `airline_colors.dart` extraído para compartilhar entre `flight_results_page` e `flight_detail_page`.
- *Ícone/cor de companhia em Minhas Viagens*: mapa duplicado em `dbook_feature_booking` de propósito (features não se importam).

## Perguntas antes de mexer em estrutura

1. Existe irmão que já resolve isso? Imite-o.
2. Esta mudança faz um pacote importar o que não devia (feature→feature, design_system→domain, domain→Flutter)?
3. Estou criando abstração/pacote para um único uso? Haverá 2º uso **de verdade**?
4. Isso é dado/função real do backend, ou estou fabricando algo que a referência visual sugere?
5. Muda o contrato com o backend? Ele é o dono — combine antes (veja `../dbook`).
6. Como eu testaria? Se exige montar o app inteiro para provar uma regra, ela está no pacote errado.

Mudança estrutural relevante vira item no `CHECKLIST.md` (seção do marco) com o **porquê**.
