---
name: code-review
description: Revisão de código do app Flutter DBook Mobile, focada em problemas reais (violação de fronteira entre pacotes, front burro quebrado, tratamento de erro/async, lifecycle e context.mounted, estado Riverpod, contrato com o backend, testes ausentes) e não em estilo cosmético. Use SEMPRE que o pedido for revisar um diff, PR, branch ou trecho deste repositório, ou quando o dono perguntar "tá bom?", "revisa isso", "antes de commitar" — e como autorrevisão final antes de declarar uma tarefa pronta.
---

# Code review — DBook Mobile

**Princípio:** só vale comentário que aponta algo que quebra, engana o usuário, vaza estado, esconde bug ou encarece a próxima mudança. `flutter analyze` e `dart format` já cobrem estilo — **não repita o que a ferramenta pega**; rode e cite só o que sobra. Sem problema real? Diga isso; não fabrique sugestão.

## Como revisar

1. Leia o diff inteiro e depois o **irmão mais próximo** de cada arquivo novo (notifier/page/teste parecido). Desvio do padrão existente é o achado mais comum.
2. Percorra os eixos na ordem (mais grave primeiro).
3. Rode `melos run analyze` (ou `flutter analyze` no pacote) e os testes afetados; relate o que rodou.
4. Escreva o **impacto concreto** ("usuário vê taxa que não existe"), não a regra abstrata.

## Eixos (o que procurar neste projeto)

**1. Front burro / honestidade da UI (prioridade máxima)**
- Dado de negócio hardcoded (lista, preço, taxa, política) ou item copiado da referência visual **sem dado/endpoint real** (ex.: "Taxes & Fees", "Save card", chips de bagagem)? Botão/campo que promete algo sem função por trás?
- Texto de erro de negócio inventado no app em vez de `error.message` do backend.

**2. Arquitetura / fronteiras de pacote**
- Feature importando outra feature (olhar `pubspec.yaml` e imports); `dbook_design_system` importando `dbook_domain`; `dbook_domain` importando Flutter/Dio; JSON/`Dio` fora de `dbook_core_network`.
- Página navegando para fora de si em vez de reportar por callback; regra no widget; estado duplicado; novo fetch para dado já em provider.
- Abstração/use case "por simetria" (as features leem o repositório direto).

**3. Correção, erros e async**
- `catch (_)`/`catch (e)` genérico; `DbookNetworkException` não tratada (a tela trava em loading?); estado de erro que **destrói** o contexto da tela (o padrão é o estado "hub").
- `context` usado depois de `await` sem `context.mounted`; `setState`/`ref` após `dispose`; navegação dentro de `build` sem `ref.listen`.
- Invalidação esquecida depois de mutação (`ref.invalidate(myBookingsNotifierProvider)`), ou invalidação excessiva.
- Loading infinito: `Future` que nunca completa o estado; botão sem proteção de duplo toque (`isLoading`).

**4. Lifecycle e recursos**
- `TextEditingController`/`AnimationController`/subscription sem `dispose`. `ref.watch` em callback (deveria ser `ref.read`) ou `ref.read` em `build` (não reativo).
- Conexão WebSocket/stream sem fechar; timers sem cancelamento.

**5. Segurança**
- Token/segredo em código ou log (`dbookNetworkLoggingProvider` só com `kDebugMode`); dado sensível trafegando sem necessidade (cartão: só `cardLast4` + nome saem do dispositivo; número/CVV **nunca**).
- `baseUrl` hardcoded fora do `main()`; HTTP em produção.

**6. Contrato com o backend (`../dbook`)**
- DTO/entidade batem com o JSON real? Campo novo obrigatório que o backend ainda não manda quebra o app. Enum de fio novo sem `wire_enums`. Mudou DTO → o teste do DTO acompanhou?
- Endpoint/status assumido sem conferir o backend.

**7. UI / performance (só com evidência)**
- `RenderFlex overflow` provável (coluna sem rolagem, texto longo); imagem de rede sem fallback; lista grande sem `ListView.builder`; `build` fazendo trabalho pesado; rebuild amplo por `ref.watch` do provider inteiro onde `select` resolve. Número/cor solta fora dos tokens do design system.
- Acessibilidade só quando o componente for novo e interativo (área de toque, `Semantics`) — não gere lista genérica.

**8. Testes**
- Caminho feliz **e** erro/vazio/loading cobertos? Padrão `given/when/then`, fake à mão, `ProviderScope` com override? Tela virou `ConsumerWidget` e o teste ganhou `ProviderScope`?
- Teste que passa pelo motivo errado; `pumpAndSettle` mascarando loader infinito; tempo real em vez de `fake_async`; nova lib de mock.
- `*.freezed.dart`/`*.g.dart` regenerados e **incluídos** no commit quando mexeu em freezed/DTO?
- Cobertura combinada ainda ≥ 80% (`melos run coverage` + `combine_coverage.sh`)?

**9. Complexidade/legibilidade** (só se atrapalhar de verdade): widget gigante que mistura estado, formulário e layout; duplicação que componente/helper existente resolve; nome enganoso; comentário que descreve o *quê* em vez do *porquê*.

## Formato do relatório

```
## Veredito: <aprovar | aprovar com ressalvas | pedir mudanças>
### Bloqueadores       (quebra, engana o usuário, vaza — corrigir antes de mergear)
- <arquivo:linha> — <problema> → <impacto concreto> → <correção sugerida>
### Importantes        (bug provável, teste faltando, quebra de padrão relevante)
### Observações        (opcional, no máximo 3, só com benefício real)
### Validações executadas
- analyze: <resultado>; testes: <o que rodou / não rodou e por quê>; visual: <verificado no app? sim/não>
```

Ordene por gravidade, um achado por item. Sem elogio genérico nem lista de nits de formatação. O que você suspeita mas não confirmou vai como **suspeita** com a forma de verificar. Mudança visual não verificada no app rodando deve ser declarada como tal.
