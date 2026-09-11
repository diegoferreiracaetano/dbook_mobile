#!/usr/bin/env bash
# Junta o coverage/lcov.info de cada pacote (gerado por `melos run coverage`)
# num único coverage/lcov.info na raiz, pro `very_good_coverage` checar.
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p coverage
: > coverage/lcov.info

find . \
  -path './coverage/lcov.info' -prune -o \
  -path '*/coverage/lcov.info' -print |
  while read -r file; do
    cat "$file" >> coverage/lcov.info
  done

echo "Combined into coverage/lcov.info"
