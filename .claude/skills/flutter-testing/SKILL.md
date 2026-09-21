---
name: flutter-testing
description: Convenções de teste do app Flutter DBook Mobile — given/when/then, fakes escritos à mão (sem mocktail/mockito), ProviderScope/ProviderContainer com overrides, testWidgets com MaterialApp+DbookTheme, testWidgetsWithMockImages, fake_async, testes de DTO/domínio, cobertura combinada ≥ 80% e comandos oficiais do melos. Use SEMPRE que for escrever, revisar, consertar ou rodar testes deste repositório, ou quando uma feature/tela nova precisar de cobertura, mesmo que o pedido diga só "testa isso".
---

# Testes no DBook Mobile

Estratégia real (~70 arquivos `*_test.dart` + 21 testes de fluxo no app): muitos **testes de notifier/widget/DTO com fakes manuais**, tempo controlado com `fake_async`, e **um** `integration_test` (device) fora do caminho padrão. **Não existe lib de mock no projeto.**

## Qual tipo usar

| Sujeito | Onde | Como |
|---|---|---|
| Entidade / use case (`dbook_domain`) | `test/entities`, `test/use_cases` | `package:test`, fake do repositório |
| DTO / repositório de rede | `dbook_core_network/test/{dtos,repositories}` | JSON real → `fromJson` → `toDomain`; repositório com um `Dio()` de teste + `_FakeResponseInterceptor` que devolve resposta enlatada/`DioException` sem rede (ver `flight_repository_impl_test.dart`) |
| Notifier / estado | `<feature>/test/state` | `ProviderContainer` + overrides |
| Página / componente | `<feature>/test/ui`, `dbook_design_system/test/components` | `testWidgets` + `MaterialApp(theme: DbookTheme.light)` |
| Cliente com timer/reconexão | `dbook_feature_realtime/test/data` | `fakeAsync` |
| Fluxo do app inteiro (Auth Gate, jornada) | `apps/dbook_mobile/test/widget_test.dart` | `ProviderScope` com repositórios fake, sem device |
| App em device real | `apps/dbook_mobile/integration_test/app_test.dart` | só quando pedirem; precisa de emulador |

Suba o **menor contexto** que prova o comportamento: regra de domínio não precisa de widget; tela não precisa de rede.

## Nomenclatura

`'given <contexto> when <ação> then <resultado>'` (inglês), string única em `test()`/`testWidgets()`. Arquivo `<sujeito>_test.dart` espelhando `lib/`. Vários cenários por arquivo são normais aqui (diferente do backend).

## Exemplos reais

**Fake à mão + use case** (`dbook_domain/test/use_cases/register_booking_use_case_test.dart`):
```dart
class _FakeBookingRepository implements BookingRepository {
  int? capturedBookableId;
  @override
  Future<Booking> create({required int bookableId, required int seatId}) async {
    capturedBookableId = bookableId;
    return Booking(id: 1, bookableId: bookableId, seatId: seatId, customerId: 5, status: BookingStatus.pending);
  }
  // demais métodos da porta...
}
test('given a seat when registering a booking then forwards params and returns a pending booking', () async {
  final repository = _FakeBookingRepository();
  final booking = await RegisterBookingUseCase(repository)(bookableId: 10, seatId: 100);
  expect(repository.capturedBookableId, 10);
  expect(booking.status, BookingStatus.pending);
});
```

**Notifier** (`dbook_feature_booking/test/state/payment_notifier_test.dart`):
```dart
ProviderContainer _buildContainer({required PaymentRepository paymentRepository, required BookingRepository bookingRepository}) {
  final container = ProviderContainer(overrides: [
    paymentRepositoryProvider.overrideWithValue(paymentRepository),
    bookingRepositoryProvider.overrideWithValue(bookingRepository),
  ]);
  addTearDown(container.dispose);
  return container;
}
// erro simulado pelo fake:  _FakePaymentRepository(error: const DbookConflictException('Booking is no longer PENDING'))
final state = container.read(paymentNotifierProvider);
expect(state, isA<PaymentError>());
expect((state as PaymentError).message, 'Booking is no longer PENDING');
```
Invalidação provada por `callCount` do fake: leia o provider (count 1) → aja → leia de novo (count 2).

**Widget com Riverpod** (`payment_page_test.dart`):
```dart
Widget _wrap(Widget child, {required PaymentRepository paymentRepository}) => ProviderScope(
  overrides: [paymentRepositoryProvider.overrideWithValue(paymentRepository)],
  child: MaterialApp(theme: DbookTheme.light, home: child),
);
await tester.enterText(find.widgetWithText(TextFormField, 'Card number'), '4242 4242 4242 4242');
await tester.tap(find.text('Pay \$800.00'));
await tester.pumpAndSettle();
expect(paymentRepository.capturedCardLast4, '4242');      // só o necessário chega ao repositório
expect(find.textContaining('Tax'), findsNothing);          // front burro: nada fabricado
```

**Callback de página** (`seat_selection_page_test.dart`): passe `onBooked: (booking, _, seat) { bookedBooking = booking; }` e assert nas variáveis capturadas após `pumpAndSettle`.

**Imagem de rede** (`flight_detail_page_test.dart`): `testWidgetsWithMockImages('...', (tester) async { ... })` de `dbook_feature_flights/test/support/mock_network_image.dart`; sem isso `Image.network` derruba o teste. Cubra os **dois** caminhos: com foto (`find.byType(Image)` → 1) e sem (→ 0, fallback).

**Tempo** (`stomp_availability_client_test.dart`): `fakeAsync((async) { ...; async.flushMicrotasks(); async.elapse(const Duration(seconds: 2)); ... })`.

## O que cobrir por feature nova

Notifier: estado inicial, sucesso, **cada** `DbookNetworkException` relevante, efeitos colaterais (invalidação). Página: renderiza os dados certos, estado de loading/erro/vazio, ação dispara a chamada certa (e **não** dispara quando a validação falha), o que **não** deve aparecer. DTO: JSON real + enum desconhecido (`FormatException`).

## Assincronismo e determinismo

- `pump()` para um frame, `pumpAndSettle()` quando a animação assenta (loader/animação infinita nunca assenta — use `pump(Duration)`).
- Datas fixas (`DateTime(2026, 1, 13, 10, 30)`); ids explícitos; nada de `DateTime.now()` na asserção.
- Timer/backoff/reconexão só com `fake_async`. **Proibido** `Future.delayed`/sleep reais e teste dependente de ordem ou rede.
- Tela que virou `ConsumerWidget` exige `ProviderScope` no teste (e override do repositório).

## Proibido

- Adicionar mocktail/mockito/etc. sem pedido; mockar o que um fake de 10 linhas resolve.
- Enfraquecer asserção ou apagar teste para ficar verde; `find` por texto que muda a cada cópia sem necessidade.
- Testar detalhe interno (widget privado, ordem interna) em vez de comportamento.
- `integration_test` para o que um widget test prova.

## Comandos e cobertura

```bash
cd packages/dbook_feature_booking && flutter test test/ui/payment_page_test.dart   # estreito
cd packages/dbook_feature_booking && flutter analyze && flutter test
melos run test            # pacotes Flutter
melos run test:dart       # dbook_domain e dbook_core_network (dart test)
melos run coverage && melos run coverage:dart && ./tool/combine_coverage.sh
python3 -c "
lf=lh=0
for l in open('coverage/lcov.info'):
    if l.startswith('LF:'): lf+=int(l[3:])
    elif l.startswith('LH:'): lh+=int(l[3:])
print(f'{lh}/{lf} = {100*lh/lf:.2f}%')"
```
CI (`very_good_coverage`) exige **≥ 80%** combinado; último valor conhecido **82.01%**. Não exclua código para subir o número. Saída barulhenta de `google_fonts` nos testes do design system não é falha — vale o `All tests passed!`.

Formatação: `dart format <arquivos de teste tocados>` (não reformate arquivos alheios — há drift pré-existente em ~10 arquivos).
