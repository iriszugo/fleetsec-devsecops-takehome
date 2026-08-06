#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"
REPORT_DIR="$ROOT_DIR/reports/day1-verification"
IMAGE_NAME="fleetsec-app:day1-verification"
CONTAINER_NAME="fleetsec-day1-verification"

PASS_COUNT=0
FAIL_COUNT=0

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

mkdir -p "$REPORT_DIR"

cleanup() {
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

trap cleanup EXIT

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

echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW} FleetSec — Verificación Funcional del Día 1${NC}"
echo -e "${YELLOW}=====================================================${NC}"

cd "$ROOT_DIR"

echo

echo "1. Validación de rama Git"

CURRENT_BRANCH="$(git branch --show-current)"

if [[ "$CURRENT_BRANCH" =~ ^feature/day1- ]] || \
   [[ "$CURRENT_BRANCH" =~ ^feature/day2- ]] || \
   [[ "$CURRENT_BRANCH" =~ ^feature/day3- ]] || \
   [[ "$CURRENT_BRANCH" == "main" ]]; then

    pass "Rama válida para regresión: $CURRENT_BRANCH"

else

    fail "Rama incorrecta: $CURRENT_BRANCH"

fi


echo "2. Validación de estructura"

check_file "app/package.json"
check_file "app/package-lock.json"
check_file "app/src/app.js"
check_file "app/src/server.js"
check_file "app/src/database.js"
check_file "app/test/health.test.js"
check_file "app/Dockerfile"
check_file "app/.dockerignore"
check_file "app/.gitignore"
check_file "app/.semgrep/fleetsec-sqli.yml"
check_file ".semgrep/fleetsec-sensitive-logging.yml"
check_file "app/tests/semgrep/pii-logging-positive.js"
check_file "app/tests/semgrep/pii-logging-negative.js"
check_file "reports/sbom/bom.json"
check_file "docs/security/suppressions.md"
check_file "docs/adr/0001-node-express-vulnerable-lab.md"
check_file ".github/workflows/devsecops-pipeline.yml"
check_file "scripts/evaluate-trivy-sca.sh"

echo
echo "3. Instalación reproducible y pruebas"

if (
    cd "$APP_DIR" &&
    npm ci
) >"$REPORT_DIR/npm-ci.log" 2>&1; then
    pass "npm ci"
else
    fail "npm ci"
fi

if (
    cd "$APP_DIR" &&
    npm test
) >"$REPORT_DIR/npm-test.log" 2>&1; then
    pass "Pruebas Jest"
else
    fail "Pruebas Jest"
fi

echo
echo "4. Validación del SBOM"

if jq empty "$ROOT_DIR/reports/sbom/bom.json" >/dev/null 2>&1; then
    pass "SBOM JSON válido"
else
    fail "SBOM JSON inválido"
fi

if jq -e '.bomFormat == "CycloneDX"' \
    "$ROOT_DIR/reports/sbom/bom.json" >/dev/null 2>&1; then
    pass "Formato CycloneDX"
else
    fail "Formato CycloneDX no identificado"
fi

echo


echo
echo "5. Validación Semgrep"

# Compatibilidad con la evolución del laboratorio.
# Día 1: SQLi estaba en app/src/app.js.
# Día 2 en adelante: SQLi está aislado en app/lab/vulnerable/sqli.js.

if [[ -f "$APP_DIR/lab/vulnerable/sqli.js" ]]; then
    SQLI_TARGET="$APP_DIR/lab/vulnerable/sqli.js"
else
    SQLI_TARGET="$APP_DIR/src/app.js"
fi

rm -f "$REPORT_DIR/semgrep-sqli.json"

semgrep scan \
    --config "$APP_DIR/.semgrep/fleetsec-sqli.yml" \
    "$SQLI_TARGET" \
    --json \
    >"$REPORT_DIR/semgrep-sqli.json" 2>/dev/null || true

SQLI_FINDINGS="$(
    jq -r '.results | length' \
        "$REPORT_DIR/semgrep-sqli.json" 2>/dev/null || echo 0
)"

if [[ "$SQLI_FINDINGS" -ge 1 ]]; then
    pass "Regla Semgrep SQLi detecta CWE-89"
else
    fail "Regla Semgrep SQLi sin hallazgos"
fi

rm -f "$REPORT_DIR/semgrep-pii-positive.json"

semgrep scan \
    --config "$ROOT_DIR/.semgrep/fleetsec-sensitive-logging.yml" \
    "$APP_DIR/tests/semgrep/pii-logging-positive.js" \
    --json \
    >"$REPORT_DIR/semgrep-pii-positive.json" 2>/dev/null || true

PII_POSITIVE_FINDINGS="$(
    jq -r '.results | length' \
        "$REPORT_DIR/semgrep-pii-positive.json" 2>/dev/null || echo 0
)"

if [[ "$PII_POSITIVE_FINDINGS" -eq 2 ]]; then
    pass "Caso positivo PII genera 2 hallazgos"
else
    fail "Caso positivo PII generó $PII_POSITIVE_FINDINGS hallazgos"
fi

rm -f "$REPORT_DIR/semgrep-pii-negative.json"

semgrep scan \
    --config "$ROOT_DIR/.semgrep/fleetsec-sensitive-logging.yml" \
    "$APP_DIR/tests/semgrep/pii-logging-negative.js" \
    --json \
    >"$REPORT_DIR/semgrep-pii-negative.json" 2>/dev/null || true

PII_NEGATIVE_FINDINGS="$(
    jq -r '.results | length' \
        "$REPORT_DIR/semgrep-pii-negative.json" 2>/dev/null || echo 0
)"

if [[ "$PII_NEGATIVE_FINDINGS" -eq 0 ]]; then
    pass "Caso negativo PII sin falsos positivos"
else
    fail "Caso negativo PII generó $PII_NEGATIVE_FINDINGS hallazgos"
fi




echo "6. Validación de secretos"

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

echo
echo "7. Validación Docker"

if docker build \
    -t "$IMAGE_NAME" \
    "$APP_DIR" >"$REPORT_DIR/docker-build.log" 2>&1; then
    pass "Construcción de imagen Docker"
else
    fail "Construcción de imagen Docker"
fi

if docker run -d \
    --name "$CONTAINER_NAME" \
    -p 127.0.0.1:3001:3000 \
    "$IMAGE_NAME" >"$REPORT_DIR/container-id.txt" 2>&1; then
    pass "Inicio del contenedor"
else
    fail "Inicio del contenedor"
fi

sleep 5

if curl --fail --silent \
    http://127.0.0.1:3001/health \
    >"$REPORT_DIR/health.json"; then
    pass "Endpoint /health"
else
    fail "Endpoint /health"
fi

CONTAINER_USER="$(
    docker inspect "$CONTAINER_NAME" \
        --format='{{.Config.User}}' 2>/dev/null || true
)"

if [[ -n "$CONTAINER_USER" &&
      "$CONTAINER_USER" != "root" &&
      "$CONTAINER_USER" != "0" ]]; then
    pass "Contenedor ejecuta como usuario no root: $CONTAINER_USER"
else
    fail "Contenedor ejecuta como root o sin usuario definido"
fi

echo
echo "8. Validación Trivy"

if trivy fs \
    --format json \
    --output "$REPORT_DIR/trivy-results.json" \
    "$APP_DIR" >/dev/null 2>&1; then
    pass "Reporte Trivy filesystem"
else
    fail "Escaneo Trivy filesystem"
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
echo "9. Validación de scripts y workflow"

if bash -n "$ROOT_DIR/scripts/evaluate-trivy-sca.sh"; then
    pass "Sintaxis evaluate-trivy-sca.sh"
else
    fail "Sintaxis evaluate-trivy-sca.sh"
fi

if grep -qE '^[[:space:]]+security-summary:' \
    "$ROOT_DIR/.github/workflows/devsecops-pipeline.yml"; then
    pass "Job security-summary presente"
else
    fail "Job security-summary ausente"
fi

if grep -q "semgrep-sarif" \
    "$ROOT_DIR/.github/workflows/devsecops-pipeline.yml"; then
    pass "Artefacto Semgrep SARIF configurado"
else
    fail "Artefacto Semgrep SARIF ausente"
fi

if grep -q "evaluate-trivy-sca.sh" \
    "$ROOT_DIR/.github/workflows/devsecops-pipeline.yml"; then
    pass "Quality Gate Trivy integrado al pipeline"
else
    fail "Quality Gate Trivy ausente del pipeline"
fi

echo
echo -e "${YELLOW}=====================================================${NC}"
echo "PASS: $PASS_COUNT"
echo "FAIL: $FAIL_COUNT"
echo -e "${YELLOW}=====================================================${NC}"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo -e "${RED}RESULTADO: VERIFICACIÓN DEL DÍA 1 FALLIDA${NC}"
    exit 1
fi

echo -e "${GREEN}RESULTADO: VERIFICACIÓN DEL DÍA 1 APROBADA${NC}"
exit 0
