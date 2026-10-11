#!/usr/bin/env bash
# Orçamento de tamanho do bundle do portal. Falha se o JavaScript principal
# (gzip, o que o navegador de fato baixa) passar do limite em KB.
#   ./tool/check_bundle_size.sh apps/dbook_admin/build/web 1500
set -euo pipefail
dir="${1:?uso: check_bundle_size.sh <pasta do build web> <limite em KB gzip>}"
limit_kb="${2:?informe o limite em KB}"

main="$dir/main.dart.js"
[ -f "$main" ] || { echo "FALHA: $main não existe (rode flutter build web antes)"; exit 1; }

size_kb=$(( $(gzip -c "$main" | wc -c) / 1024 ))
echo "main.dart.js: ${size_kb} KB gzip (limite ${limit_kb} KB)"

for part in "$dir"/main.dart.js_*.part.js; do
  [ -f "$part" ] || continue
  echo "$(basename "$part"): $(( $(gzip -c "$part" | wc -c) / 1024 )) KB gzip (carregado sob demanda)"
done

if [ "$size_kb" -gt "$limit_kb" ]; then
  echo "FALHA: o bundle principal estourou o orçamento em $(( size_kb - limit_kb )) KB"
  exit 1
fi
echo "ok: dentro do orçamento"
