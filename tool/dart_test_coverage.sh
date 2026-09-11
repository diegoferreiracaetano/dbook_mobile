#!/usr/bin/env bash
# Roda `dart test --coverage` e converte pra lcov — melos exec chama isso
# de dentro de cada pacote Dart puro (cwd já é a raiz do pacote).
set -euo pipefail

dart test --coverage=coverage
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib \
  --package=. \
  --ignore-files='lib/**.freezed.dart,lib/**.g.dart'
