# DBook Mobile

Cliente Flutter do [DBook](../dbook) — consome a API de reservas de voos construída no projeto backend.

Monorepo gerenciado com [melos](https://melos.invertase.dev/), sobre o suporte nativo do Dart a [pub workspaces](https://dart.dev/tools/pub/workspaces).

## Estrutura

```
apps/
  dbook_mobile/                 # app Flutter de verdade
packages/
  dbook_design_system/          # tokens, tema e componentes compartilhados
    sample/                     # app de exemplo mostrando o design system
    widgetbook/                 # catálogo visual (Widgetbook)
```

## Rodando localmente

Resolver o workspace inteiro a partir da raiz:

```bash
flutter pub get
```

Scripts do melos (rodam em todos os pacotes do workspace):

```bash
melos run analyze   # flutter analyze
melos run format     # dart format --set-exit-if-changed .
melos run test        # flutter test (só nos pacotes com pasta test/)
```

Rodar cada app individualmente:

```bash
cd apps/dbook_mobile && flutter run
cd packages/dbook_design_system/sample && flutter run
cd packages/dbook_design_system/widgetbook && flutter run
```

Teste instrumentado (precisa de device/emulador real):

```bash
cd apps/dbook_mobile && flutter test integration_test/app_test.dart
```

## Progresso

Ver [CHECKLIST.md](CHECKLIST.md) para o detalhamento marco a marco.

- **M1 — Setup do monorepo + design system**: completo. `dbook_design_system` cobre tokens (cor/tipografia/espaçamento/raio/elevação/motion), tema claro/escuro, e todo o inventário de componentes extraído do UI kit de referência (ação, formulário, exibição de dados, navegação, feedback, overlays), com widget test em cada um. `apps/dbook_mobile` existe e consome o tema; a tela inicial é um onboarding de 3 slides até o fluxo de auth (M2) ser construído.
- **M2 em diante**: ainda não iniciado.
