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
  dbook_domain/                 # entidades, portas e casos de uso — Dart puro
  dbook_core_network/           # Dio, DTOs e implementação dos repositórios — Dart puro
  dbook_core_storage/           # storage seguro do par de tokens (flutter_secure_storage)
  dbook_feature_auth/           # telas de login/cadastro, sessão (Riverpod) e interceptor de token
```

## Rodando localmente

Resolver o workspace inteiro a partir da raiz:

```bash
flutter pub get
```

Scripts do melos (rodam em todos os pacotes do workspace):

```bash
melos run analyze       # flutter analyze (todos os pacotes)
melos run format        # dart format --set-exit-if-changed . (todos os pacotes)
melos run test          # flutter test (pacotes Flutter com pasta test/)
melos run test:dart     # dart test (pacotes Dart puro com pasta test/ — dbook_domain, dbook_core_network)
melos run coverage      # flutter test --coverage (pacotes Flutter)
melos run coverage:dart # dart test --coverage + conversão pra lcov (pacotes Dart puro)
```

`dbook_domain` e `dbook_core_network` usam `freezed`/`json_serializable` (codegen); depois de mexer nas entidades/DTOs, rodar `dart run build_runner build --delete-conflicting-outputs` dentro do pacote — os `.freezed.dart`/`.g.dart` ficam versionados (sem passo de codegen no CI).

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

- **M1 — Setup do monorepo + design system**: completo. `dbook_design_system` cobre tokens (cor/tipografia/espaçamento/raio/elevação/motion), tema claro/escuro, e todo o inventário de componentes extraído do UI kit de referência (ação, formulário, exibição de dados, navegação, feedback, overlays), com widget test em cada um. `apps/dbook_mobile` existe e consome o tema; a tela inicial é um onboarding de 3 slides (com fotos reais e ilustração no splash nativo) até o fluxo de auth (M2/M3) ser construído.
- **M2 — Domínio + rede**: completo. `dbook_domain` (entidades, portas, casos de uso) tem os campos batendo com o backend de verdade (survey do código-fonte, não suposição). `dbook_core_network` implementa as portas com Dio + DTOs (`freezed`/`json_serializable`) + mapeamento + exceptions por status HTTP. `dbook_core_storage` guarda o par de tokens no Keychain/EncryptedSharedPreferences.
- **M3 — Autenticação**: completo. `dbook_feature_auth` tem `LoginPage`/`RegisterPage` (montadas só com componentes do `dbook_design_system`), `AuthNotifier` (Riverpod) orquestrando loggedOut/loading/loggedIn/error, `PersistingAuthRepository` salvando o par de tokens a cada login/refresh e `DbookAuthInterceptor` anexando o access token em toda requisição + refresh automático no 401 (com deduplicação de refresh concorrente, já que o refresh token do backend é de uso único). `apps/dbook_mobile` liga tudo: `_AppRoot` faz o bootstrap de sessão na abertura do app (token salvo → pula pra tela logada; senão → onboarding → login/cadastro) e o placeholder de tela logada tem o botão de logout.
- **M4 em diante**: ainda não iniciado.
