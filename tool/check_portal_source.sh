#!/usr/bin/env bash
# Guardas de segurança do código do portal (rodam no CI):
#  1. nada de HTML injetado: todo texto de cliente (nome, nota, avaliação) é
#     desenhado como texto pelo Flutter, nunca como HTML;
#  2. nada de postMessage nem de window.open com endereço vindo de dado;
#  3. nada de segredo escrito no código.
set -euo pipefail
cd "$(dirname "$0")/.."

dirs=(apps/dbook_admin/lib packages/dbook_admin_data/lib packages/dbook_admin_session/lib \
      packages/dbook_admin_l10n/lib packages/dbook_feature_admin_*/lib)
fail=0

check() {
  local pattern="$1" message="$2"
  if grep -rEn --include='*.dart' "$pattern" "${dirs[@]}" >/dev/null 2>&1; then
    echo "FALHA: $message"
    grep -rEn --include='*.dart' "$pattern" "${dirs[@]}" || true
    fail=1
  fi
}

check "innerHTML|insertAdjacentHTML|HtmlElementView|dart:html|setInnerHtml" "HTML injetado no portal"
check "postMessage|window\.open\(" "postMessage ou window.open no portal"
check "(secret|password|apikey|api_key)[[:space:]]*[:=][[:space:]]*['\"][^'\"]{6,}['\"]" "possível segredo escrito no código"

[ "$fail" -eq 0 ] && echo "ok: nenhuma violação nas guardas do portal"
exit "$fail"
