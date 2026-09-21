---
name: flutter-development
description: Como desenvolver no app Flutter DBook Mobile — pacotes do monorepo melos, Riverpod (Notifier + freezed sealed), repositórios/DTOs com dio, design system Dbook*, navegação, tratamento de erros (DbookNetworkException), assincronismo e o princípio "front burro", com exemplos reais do código. Use SEMPRE que for criar ou alterar tela, notifier, estado, DTO, repositório, componente do design system ou fluxo de navegação neste repositório, mesmo que o pedido seja pequeno ("muda esse botão", "mostra mais um campo", "nova aba").
---

# Desenvolvimento no DBook Mobile (Flutter)

Método: **achar o irmão mais próximo e imitar**. Padrões abaixo vêm do código; se o código divergir, o código vence — atualize esta skill.

## Princípios (o porquê de várias regras abaixo)

- **Front burro:** o app só exibe o que o backend entrega; nenhum dado de negócio hardcoded e nenhum controle que prometa função inexistente. Referência visual com item sem dado real (ex.: "Taxes & Fees", "Save card") → **não implemente e diga**.
- **Design system primeiro** (token → componente → feature) e **features não importam features**.
- **Reuse dado já carregado** em vez de novo fetch (foto do destino via `featuredDestinationsProvider`).

## Receita de uma feature (de baixo para cima)

1. **`dbook_domain`** (Dart puro): entidade freezed + porta.
   ```dart
   @freezed
   abstract class Payment with _$Payment {
     const factory Payment({required int id, required double amount, required String cardLast4,
       required List<int> bookingIds, required String status}) = _Payment;
   }
   abstract interface class PaymentRepository {
     Future<Payment> pay({required List<int> bookingIds, required String cardLast4, required String cardholderName});
   }
   ```
   Exporte no barrel `dbook_domain.dart`.
2. **`dbook_core_network`**: `XxxRequestDto`/`XxxResponseDto` (freezed + `fromJson`, `toDomain()`), `XxxRepositoryImpl`:
   ```dart
   class PaymentRepositoryImpl implements PaymentRepository {
     const PaymentRepositoryImpl(this._dio);
     final Dio _dio;
     @override
     Future<Payment> pay({...}) async {
       try {
         final response = await _dio.post<Map<String, dynamic>>('/payments', data: RegisterPaymentRequestDto(...).toJson());
         return PaymentResponseDto.fromJson(response.data!).toDomain();
       } on DioException catch (error) { throw mapDioException(error); }
     }
   }
   ```
   Enum de fio novo → `wire_enums.dart` (`XxxFromWire`, lança `FormatException` se desconhecido).
3. **Feature** (`dbook_feature_<x>/lib/src/state`): providers + notifier + state freezed.
   ```dart
   final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepositoryImpl(ref.watch(dioProvider)));
   final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);

   @freezed
   sealed class PaymentState with _$PaymentState {
     const factory PaymentState.idle() = PaymentIdle;
     const factory PaymentState.submitting() = PaymentSubmitting;
     const factory PaymentState.error(String message) = PaymentError;
     const factory PaymentState.paid(Payment payment) = PaymentPaid;
   }

   class PaymentNotifier extends Notifier<PaymentState> {
     @override PaymentState build() => const PaymentState.idle();
     Future<void> pay({...}) async {
       state = const PaymentState.submitting();
       try {
         final payment = await ref.read(paymentRepositoryProvider).pay(...);
         ref.invalidate(myBookingsNotifierProvider);            // invalida o que ficou velho
         state = PaymentState.paid(payment);
       } on DbookNetworkException catch (error) { state = PaymentState.error(error.message); }
     }
   }
   ```
4. **UI** (`lib/src/ui`): `ConsumerWidget`/`ConsumerStatefulWidget`; `ref.watch` para desenhar, `ref.listen` para efeito (navegação) — nunca navegue dentro de `build` sem `ref.listen`.
5. **Barrel** `lib/dbook_feature_<x>.dart` exporta só o que o app usa (`hide` para o que é interno, ex.: `flightRepositoryProvider`).
6. **Codegen:** `dart run build_runner build` dentro do pacote; commite `*.freezed.dart`/`*.g.dart`.
7. **Composição** no `apps/dbook_mobile/lib/main.dart` se a feature precisa falar com outra.

## Página + callbacks (não navegue para fora de si)

A página reporta o resultado; quem a monta decide o próximo passo. Exemplo real:
```dart
class SeatSelectionPage extends ConsumerStatefulWidget {
  const SeatSelectionPage({super.key, required this.flight, this.onBooked});
  final void Function(Booking booking, Flight flight, Seat seat)? onBooked;
}
// no build:
ref.listen<SeatSelectionState>(seatSelectionNotifierProvider, (previous, next) {
  if (next is SeatSelectionBooked) widget.onBooked?.call(next.booking, next.flight, next.seat);
});
```
`main.dart` (`_buildSeatSelectionFor`) acumula os trechos e decide: próximo assento em silêncio ou `PaymentPage`. Dependência entre features (ex.: `liveAvailability`, `onBook`) entra por **parâmetro/callback**.

## Erros

- `core_network` traduz tudo para `DbookNetworkException` (sealed por status: 400/401/403/404/409/429/502/503/desconhecido); a mensagem vem do backend (`{"error": ...}`).
- Notifier captura `on DbookNetworkException catch (error)` e guarda `error.message`; a UI exibe **essa** mensagem (`DbookInlineStatusBanner(message: state.message, tone: DbookBannerTone.warning)` ou `DbookStatusPlaceholder`). Não invente texto de erro de negócio no app; não use `catch (_)`.
- Estado "hub": erro de ação não pode destruir a tela (ver `SeatSelectionState.ready` com `bookingError` — mantém mapa e seleção).

## Assincronismo

- `Future`/`async` simples. Depois de `await` em widget: `if (!context.mounted) return;` antes de usar `context` (ver `_confirm` em `seat_selection_page.dart`).
- `AsyncNotifier` para lista remota (`MyBookingsNotifier`), `FutureProvider` para dado compartilhado (`featuredDestinationsProvider`). `ref.invalidateSelf()` + `await future` para recarregar.
- Sem `Future.delayed` como sincronização, sem `setState` após `dispose`.

## Design system e UI

- Espaçamento `DbookSpacing.lg` etc.; raio `DbookRadius.md`; cor via `Theme.of(context).colorScheme`/`DbookStatusColors`; tema `DbookTheme.light/dark`.
- Componentes existentes antes de criar: `DbookButton`(loading embutido), `DbookAppBar`(`transparent` p/ sobrepor imagem), `DbookSuccessScreen`, `DbookInlineStatusBanner`, `DbookStatusPlaceholder`, `DbookSummaryRow`, `DbookPriceDisplay`, `DbookSeatCell`, `DbookFlightResultTile`…
- Formulário: `TextFormField` + `Form`/`GlobalKey<FormState>` + validators (`AuthValidators` em `dbook_feature_auth`, `_PaymentValidators` em `payment_page.dart`) — validação **só de formato**; o backend valida de verdade.
- Tela que pode passar da altura → `SingleChildScrollView` (já houve overflow real). Foto de rede com fallback de gradiente por cor da companhia.
- Hero com imagem: `Stack` + degradê `Color(0x00000000)→Color(0xCC000000)` + texto branco (`FlightDetailPage._HeroHeader`); `Scaffold(extendBodyBehindAppBar: true)` + `DbookAppBar(transparent: true)`.

## Navegação

- Shell de 4 abas (`IndexedStack` + `NavigationBar`), Auth Gate `pushAuthGate(context, onAuthenticated: ...)` no root navigator, jornada de reserva com `Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(...))`. `go_router` **só** dentro de `FlightsHomePage` (busca → resultados → detalhe da 1ª perna).
- Depois do login, sempre `isLoggedIn: true` nas continuações da jornada (bug real já corrigido: valor congelado reabria o gate).

## DI

Riverpod, sem get_it. `baseUrlProvider` **precisa** ser sobrescrito em `main()` (`ProviderScope(overrides: [...])`). `dioProvider` (`dbook_core_session`) é o Dio autenticado — toda feature usa esse; `authOnlyDioProvider` só para login/registro/refresh (evita loop de refresh).

## O que evitar

- Feature importando feature; `design_system` importando `dbook_domain`; regra/JSON no widget.
- Dado de negócio hardcoded; botão/campo sem função real; fabricar item de referência visual.
- `catch (_)`, texto de erro próprio para erro de negócio, esquecer `context.mounted`.
- Número/cor solta em vez de token; `Colors.white` fora de texto sobre imagem.
- Dependência nova (mock lib, bloc, get_it, riverpod_generator) sem pedido; use case "por simetria" (as features leem o repositório direto).
- Novo fetch para dado que já está em provider; estado duplicado.
- Reformatar arquivo alheio no mesmo commit; esquecer de commitar `*.freezed.dart`/`*.g.dart`.
- Refatoração fora do escopo — reporte no fim.

## Antes de entregar

`flutter analyze` (0 issues) → testes do pacote → `melos run test`/`test:dart` → `dart format` nos tocados → **abrir o app e olhar a tela** (mudança visual) → `CHECKLIST.md`/`README.md` se fechou marco. Testes: skill `flutter-testing`.
