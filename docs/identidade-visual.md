# Identidade visual e tokens

Fonte única: `packages/dbook_design_system`. Feature nenhuma monta cor, tamanho
ou fonte por conta própria. A ordem de trabalho é **token, componente, tela**.

## O que é a marca

Viagem e reserva: confiança antes de glamour. Superfícies claras e planas,
azul cobalto como única cor de ação, ciano só de apoio, números sempre
legíveis (preço, horário, assento). Nada de gradiente decorativo, sombra
pesada ou ornamento sem função.

## Tokens

| Token | Arquivo | Regra |
|---|---|---|
| Cor da marca e neutros | `dbook_colors.dart` (`DbookPalette`) | Só o tema lê a paleta; a feature usa `ColorScheme` |
| Esquema claro/escuro | `DbookColorScheme` | Todo par texto/fundo cumpre AA (4,5:1), travado em `dbook_theme_contrast_test.dart` |
| Status (sucesso, aviso, perigo, info) | `DbookStatusColors` | Trio texto, fundo e borda; nunca `Colors.green` |
| Cor categórica (companhia, série de gráfico) | `DbookCategoricalColors` | Não significa estado; contraste AA com texto branco |
| Espaçamento | `DbookSpacing` | Base 4 (xxs 2 até xxxl 48) |
| Dimensões fixas | `DbookSizes` | Altura de bloco em carregamento, coluna de rótulo |
| Raio | `DbookRadius` | Ver regra de forma abaixo |
| Elevação | `DbookElevation` | Cartão é plano; sombra só em sobreposição |
| Tipografia | `DbookTypography` | Roboto empacotada; `tabular` para números em coluna; `mono` para códigos |
| Movimento | `DbookMotion` | 150, 250 e 400 ms; curvas padrão e de entrada |

## Regra de forma

Botões e chips em pílula. Campos de formulário `md` (12). Cartões, folhas e
diálogos `lg` (16). Cartão é superfície branca com contorno `outlineVariant`,
sem sombra: a hierarquia vem da borda e do espaço, não de elevação.

## Tipografia

Roboto (Apache 2.0), pesos 400, 500, 700 e 900 em `assets/fonts/`,
**empacotada no pacote** (não vem do Google em tempo de execução). Motivo: a
CSP do portal é `font-src 'self'` e `connect-src` só na API, então uma fonte
remota seria bloqueada e o portal cairia no fallback do navegador. Roboto não
tem peso 600: os títulos "semibold" caem no 700. Números com `tnum` onde há
coluna. Foi a escolha do dono depois de testar Manrope.

## Cor e contraste (medido)

| Par | Razão |
|---|---|
| Branco sobre azul primário `#0B66D6` | 5,40:1 |
| Primário como texto sobre superfície | 5,40:1 |
| Escuro: primário `#4DA3FF` sobre `#141E27` | 6,43:1 |
| `onSecondary` (tinta `#141E27`) sobre ciano | 7,78:1 |
| `onSecondaryContainer` sobre `secondaryContainer` | 5,33:1 |

Pendência conhecida: borda de campo no claro (1,37:1) fica abaixo dos 3:1 de
elementos de interface; precisa de decisão de design.

## O que mudou nesta revisão (2026-10-09)

- Paleta: azul primário escurecido para cumprir AA; as lacunas de contraste
  que estavam travadas como "conhecidas" foram eliminadas e o teste agora
  exige AA em todos os pares.
- Tipografia: Roboto passou a ser empacotada (antes vinha do CDN e nem
  carregava sob a CSP). Manrope foi experimentada e descartada por escolha do
  dono.
- Forma: cartão plano com contorno, campos `md`.
- Tokenização: ~55 valores soltos nas features viraram token
  (`DbookSizes`, `DbookCategoricalColors`, `DbookTypography.mono`,
  `DbookFieldError`); a cor de companhia, que estava duplicada e divergia entre
  a busca e "Minhas viagens", agora é uma só.
