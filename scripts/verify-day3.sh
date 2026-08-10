#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}


echo "======================================================"
echo " FleetSec — Verificación Funcional del Día 3"
echo "======================================================"

export FLEETSEC_REGRESSION_MODE=1

#########################################################
# Regresión Día 1
#########################################################

DAY1_LOG="$(mktemp)"

if FLEETSEC_REGRESSION_MODE=1 bash "$ROOT_DIR/scripts/verify-day1.sh" >"$DAY1_LOG" 2>&1; then
    pass "Regresión Día 1"
else
    fail "Regresión Día 1"
    echo "===== LOG REGRESIÓN DÍA 1 ====="
    cat "$DAY1_LOG"
fi

rm -f "$DAY1_LOG"


#########################################################
# Regresión Día 2
#########################################################

DAY2_LOG="$(mktemp)"

if FLEETSEC_REGRESSION_MODE=1 bash "$ROOT_DIR/scripts/verify-day2.sh" >"$DAY2_LOG" 2>&1; then
    pass "Regresión Día 2"
else
    fail "Regresión Día 2"
    echo "===== LOG REGRESIÓN DÍA 2 ====="
    cat "$DAY2_LOG"
fi

rm -f "$DAY2_LOG"


#########################################################
# Archivos
#########################################################

FILES=(
app/lab/vulnerable/command-injection.js
app/src/routes/system.js
app/tests/security/command-injection.test.js
app/tests/semgrep/command-injection-positive.js
app/tests/semgrep/command-injection-negative.js
app/.semgrep/fleetsec-command-injection.yml
docs/vapt/0007-command-injection.md
)

for file in "${FILES[@]}"; do
    if [[ -f "$ROOT_DIR/$file" ]]; then
        pass "$file"
    else
        fail "$file"
    fi
done

#########################################################
# Sintaxis
#########################################################

node -c "$APP_DIR/lab/vulnerable/command-injection.js" >/dev/null \
&& pass "Lab JS válido" \
|| fail "Lab JS"

if node -c "$APP_DIR/src/routes/system.js" >/dev/null; then
    pass "Ruta segura"
else
    fail "Ruta segura"
fi


#########################################################
# Jest
#########################################################

cd "$APP_DIR"

npx jest tests/security/command-injection.test.js --runInBand >/dev/null \
&& pass "Jest Day3" \
|| fail "Jest Day3"

#########################################################
# Semgrep
#########################################################

semgrep scan \
--config "$APP_DIR/.semgrep/fleetsec-command-injection.yml" \
"$APP_DIR/tests/semgrep/command-injection-positive.js" \
>/dev/null \
&& pass "Semgrep positivo" \
|| fail "Semgrep positivo"

semgrep scan \
--config "$APP_DIR/.semgrep/fleetsec-command-injection.yml" \
"$APP_DIR/tests/semgrep/command-injection-negative.js" \
>/dev/null \
&& pass "Semgrep negativo" \
|| fail "Semgrep negativo"

#########################################################

echo
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [[ "$FAIL" -eq 0 ]]; then
    echo
    echo "RESULTADO AUDITORÍA DÍA 3: PASS"
    exit 0
fi

echo
echo "RESULTADO AUDITORÍA DÍA 3: FAIL"

exit 1
