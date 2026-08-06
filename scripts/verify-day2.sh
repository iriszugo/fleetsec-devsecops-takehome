#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"
REPORT_DIR="$ROOT_DIR/reports/day2-verification"

PASS_COUNT=0
FAIL_COUNT=0

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

mkdir -p "$REPORT_DIR"

pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_file() {
  local relative_path="$1"

  if [[ -f "$ROOT_DIR/$relative_path" ]]; then
    pass "Archivo existe: $relative_path"
  else
    fail "Archivo faltante: $relative_path"
  fi
}

check_javascript() {
  local relative_path="$1"

  if node -c "$ROOT_DIR/$relative_path" >/dev/null 2>&1; then
    pass "Sintaxis JavaScript: $relative_path"
  else
    fail "Sintaxis JavaScript inválida: $relative_path"
  fi
}

check_semgrep_fixture() {
  local rule="$1"
  local fixture="$2"
  local expected="$3"
  local output_file="$REPORT_DIR/$(basename "$fixture" .js).json"

  semgrep scan \
    --config "$ROOT_DIR/$rule" \
    "$ROOT_DIR/$fixture" \
    --json \
    --output "$output_file" \
    >/dev/null 2>&1 || true

  local findings
  findings="$(
    jq -r '.results | length' "$output_file" 2>/dev/null || echo 0
  )"

  if [[ "$expected" == "positive" && "$findings" -ge 1 ]]; then
    pass "Fixture positivo detectado: $fixture ($findings hallazgo/s)"
  elif [[ "$expected" == "negative" && "$findings" -eq 0 ]]; then
    pass "Fixture negativo limpio: $fixture"
  else
    fail "Resultado inesperado en $fixture: $findings hallazgo/s"
  fi
}

echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW} FleetSec — Verificación Funcional del Día 2${NC}"
echo -e "${YELLOW}=====================================================${NC}"

cd "$ROOT_DIR"

echo


echo "1. Rama y regresión del Día 1"

CURRENT_BRANCH="$(git branch --show-current)"

if [[ "$CURRENT_BRANCH" =~ ^feature/day2- ]] || \
   [[ "$CURRENT_BRANCH" =~ ^feature/day3- ]] || \
   [[ "$CURRENT_BRANCH" == "main" ]]; then

    pass "Rama válida para regresión: $CURRENT_BRANCH"

else

    fail "Rama incorrecta: $CURRENT_BRANCH"

fi

if "$ROOT_DIR/scripts/verify-day1.sh" >/dev/null; then
    pass "Regresión Día 1"
else
    fail "Regresión Día 1"
fi


echo "2. Dependencias"

if (
  cd "$APP_DIR" &&
  npm ci
) >"$REPORT_DIR/npm-ci.log" 2>&1; then
  pass "npm ci reproducible"
else
  fail "npm ci"
fi

for dependency in jsonwebtoken axios express-rate-limit; do
  if (
    cd "$APP_DIR" &&
    npm ls "$dependency"
  ) >"$REPORT_DIR/npm-ls-$dependency.log" 2>&1; then
    pass "Dependencia instalada: $dependency"
  else
    fail "Dependencia faltante: $dependency"
  fi
done

echo
echo "3. Estructura del laboratorio"

FILES=(
  "app/lab/vulnerable/jwt.js"
  "app/lab/vulnerable/ssrf.js"
  "app/lab/vulnerable/path-traversal.js"
  "app/lab/vulnerable/rate-limit.js"
  "app/lab/vulnerable/idor.js"
  "app/src/routes/auth.js"
  "app/src/routes/fetch.js"
  "app/src/routes/files.js"
  "app/src/routes/login.js"
  "app/src/routes/users.js"
  "app/src/middleware/auth.js"
)

for file in "${FILES[@]}"; do
  check_file "$file"
done

echo
echo "4. Sintaxis JavaScript"

for file in "${FILES[@]}"; do
  check_javascript "$file"
done

echo
echo "5. Reglas Semgrep"

RULES=(
  "app/.semgrep/fleetsec-jwt-none.yml"
  "app/.semgrep/fleetsec-ssrf.yml"
  "app/.semgrep/fleetsec-path-traversal.yml"
  "app/.semgrep/fleetsec-missing-rate-limit.yml"
  "app/.semgrep/fleetsec-idor.yml"
)

for rule in "${RULES[@]}"; do
  check_file "$rule"

  if semgrep --validate \
    --config "$ROOT_DIR/$rule" \
    >/dev/null 2>&1; then
    pass "Regla Semgrep válida: $rule"
  else
    fail "Regla Semgrep inválida: $rule"
  fi
done

echo
echo "6. Fixtures Semgrep positivos y negativos"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-jwt-none.yml" \
  "app/tests/semgrep/jwt-positive.js" \
  "positive"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-jwt-none.yml" \
  "app/tests/semgrep/jwt-negative.js" \
  "negative"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-ssrf.yml" \
  "app/tests/semgrep/ssrf-positive.js" \
  "positive"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-ssrf.yml" \
  "app/tests/semgrep/ssrf-negative.js" \
  "negative"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-path-traversal.yml" \
  "app/tests/semgrep/path-traversal-positive.js" \
  "positive"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-path-traversal.yml" \
  "app/tests/semgrep/path-traversal-negative.js" \
  "negative"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-missing-rate-limit.yml" \
  "app/tests/semgrep/rate-limit-positive.js" \
  "positive"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-missing-rate-limit.yml" \
  "app/tests/semgrep/rate-limit-negative.js" \
  "negative"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-idor.yml" \
  "app/tests/semgrep/idor-positive.js" \
  "positive"

check_semgrep_fixture \
  "app/.semgrep/fleetsec-idor.yml" \
  "app/tests/semgrep/idor-negative.js" \
  "negative"

echo
echo "7. Pruebas funcionales de seguridad"

if (
  cd "$APP_DIR" &&
  JWT_SECRET="day2-test-secret-minimum-32-characters" \
    npx jest tests/security --runInBand
) >"$REPORT_DIR/security-tests.log" 2>&1; then
  pass "Suite E2E Día 2: 5 suites / 12 pruebas"
else
  fail "Suite E2E Día 2"
fi

echo
echo "8. Suite completa de aplicación"

if (
  cd "$APP_DIR" &&
  JWT_SECRET="day2-test-secret-minimum-32-characters" \
    npm test -- --runInBand
) >"$REPORT_DIR/npm-test.log" 2>&1; then
  pass "Suite Jest completa"
else
  fail "Suite Jest completa"
fi

echo
echo "9. Quality Gates existentes"

if gitleaks detect \
  --source "$ROOT_DIR" \
  --no-banner \
  --redact \
  --report-format json \
  --report-path "$REPORT_DIR/gitleaks.json" \
  >/dev/null 2>&1; then
  pass "Gitleaks: cero secretos"
else
  fail "Gitleaks detectó posibles secretos"
fi

if trivy fs \
  --format json \
  --output "$REPORT_DIR/trivy-results.json" \
  "$APP_DIR" >/dev/null 2>&1; then
  pass "Trivy filesystem"
else
  fail "Trivy filesystem"
fi

if "$ROOT_DIR/scripts/evaluate-trivy-sca.sh" \
  "$REPORT_DIR/trivy-results.json" \
  "$APP_DIR/package.json" \
  >"$REPORT_DIR/trivy-gate.log" 2>&1; then
  pass "Quality Gate Trivy SCA"
else
  fail "Quality Gate Trivy SCA"
fi

echo
echo "10. Documentación pendiente"

DOCUMENTATION_FILES=(
  "docs/vapt/0001-sql-injection.md"
  "docs/vapt/0002-jwt-flaws.md"
  "docs/vapt/0003-ssrf.md"
  "docs/vapt/0004-path-traversal.md"
  "docs/vapt/0005-rate-limiting.md"
  "docs/vapt/0006-idor.md"
  "docs/AI-USAGE.md"
  "docs/security/suppressions.md"
)

for file in "${DOCUMENTATION_FILES[@]}"; do
  check_file "$file"
done

echo
echo -e "${YELLOW}=====================================================${NC}"
echo "PASS: $PASS_COUNT"
echo "FAIL: $FAIL_COUNT"
echo -e "${YELLOW}=====================================================${NC}"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo -e "${RED}RESULTADO: VERIFICACIÓN DEL DÍA 2 FALLIDA${NC}"
  exit 1
fi

echo -e "${GREEN}RESULTADO: VERIFICACIÓN DEL DÍA 2 APROBADA${NC}"
exit 0
