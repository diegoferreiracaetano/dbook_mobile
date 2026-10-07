# dbook_design_system

Tokens, tema e componentes compartilhados do DBook. Nenhuma tela define cor, espaçamento, fonte ou raio "no olho": tudo vem daqui.

Ordem de trabalho (não negociável): **tokens → componentes → telas.**

## Tokens (`lib/src/tokens/`)

| Token | O que é |
|---|---|
| `DbookPalette` | paleta primitiva da marca; só o tema a referencia |
| `DbookColorScheme` | `ColorScheme` Material 3 claro e escuro |
| `DbookStatusColors` | tons semânticos (`success`, `warning`, `danger`, `info`), cada um com texto, fundo e borda; texto sobre fundo cumpre AA (4,5:1), garantido por teste |
| `DbookTypography` | escala Material 3 em Roboto; `tabular(...)`, `dataMedium`, `dataSmall` para números de largura fixa em tabelas |
| `DbookSpacing` | escala de 4dp (`xxs` = 2 até `xxxl` = 48) |
| `DbookDensity` | medidas das telas densas do portal (linha de tabela, cabeçalho, células) |
| `DbookBreakpoints` | `compact` < 600, `medium` 600–1023, `expanded` ≥ 1024 (`DbookBreakpoints.of(context)`) |
| `DbookRadius`, `DbookElevation`, `DbookMotion` | raio, elevação (`panel` para os painéis do portal) e animação |
| `DbookFocus` | anel de foco do teclado, com contraste de 3:1 verificado por teste |

## Tema

`DbookTheme.light` / `DbookTheme.dark` são o que o `MaterialApp` consome. O tema escuro ainda não tem pares próprios nos tons semânticos (`DbookStatusColors.dark` é igual ao claro): isso entra quando o tema escuro do portal for decidido.

## Testes

- Um widget test por componente.
- `test/tokens/`: contraste (AA para texto, 3:1 para o anel de foco), breakpoints e o golden dos swatches (`goldens/status_colors.png`).
- Mudou uma cor de propósito? `flutter test test/tokens --update-goldens`, **olhe a imagem nova** e só então commite.

## Ver o resultado

```bash
cd sample && flutter run        # app de exemplo
cd widgetbook && flutter run    # catálogo visual