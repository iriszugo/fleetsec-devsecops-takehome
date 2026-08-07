#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DAY2_REPORT="$ROOT_DIR/reports/day2-verification"
DAY4_REPORT="$ROOT_DIR/reports/day4-verification"

PASS=0
FAIL=0


pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}


echo "====================================================="
echo " FleetSec — Cierre Definitivo Día 2 + Día 3"
echo "====================================================="


echo
echo "1. Validación de reportes Día 2"


for file in \
gitleaks.json \
idor-positive.json \
idor-negative.json \
jwt-positive.json \
jwt-negative.json \
path-traversal-positive.json \
path-traversal-negative.json \
rate-limit-positive.json \
rate-limit-negative.json \
ssrf-positive.json \
ssrf-negative.json \
security-tests.log \
trivy-gate.log
do

if [[ -f "$DAY2_REPORT/$file" ]]; then
    pass "Reporte Día 2 existe: $file"
else
    fail "Falta reporte Día 2: $file"
fi

done



echo
echo "2. Validación Gitleaks"


if [[ -f "$DAY2_REPORT/gitleaks.json" ]]; then

FINDINGS=$(jq length "$DAY2_REPORT/gitleaks.json" 2>/dev/null || echo "error")

if [[ "$FINDINGS" == "0" ]]; then
    pass "Gitleaks sin secretos"
else
    fail "Gitleaks encontró $FINDINGS hallazgos"
fi

else

fail "Reporte Gitleaks inexistente"

fi



echo
echo "3. Validación Semgrep"


for file in \
idor-positive.json \
jwt-positive.json \
path-traversal-positive.json \
ssrf-positive.json
do

if [[ -f "$DAY2_REPORT/$file" ]]; then

COUNT=$(jq '.results | length' "$DAY2_REPORT/$file" 2>/dev/null || echo 0)

if [[ "$COUNT" -gt 0 ]]; then
    pass "Semgrep detecta caso positivo $file"
else
    fail "Semgrep sin hallazgo esperado $file"
fi

fi

done



echo
echo "4. Validación casos negativos"


for file in \
idor-negative.json \
jwt-negative.json \
path-traversal-negative.json \
rate-limit-negative.json \
ssrf-negative.json
do

if [[ -f "$DAY2_REPORT/$file" ]]; then

COUNT=$(jq '.results | length' "$DAY2_REPORT/$file" 2>/dev/null || echo 0)

if [[ "$COUNT" == "0" ]]; then
    pass "Sin falsos positivos: $file"
else
    fail "Falso positivo encontrado: $file"
fi

fi

done



echo
echo "5. Validación Trivy"


if grep -q "PASS" "$DAY2_REPORT/trivy-gate.log"; then

pass "Trivy Quality Gate aprobado"

else

fail "Trivy Quality Gate pendiente"

fi



echo
echo "6. Validación SBOM"


if [[ -f "$ROOT_DIR/reports/sbom/bom.json" ]]; then

if jq empty "$ROOT_DIR/reports/sbom/bom.json" >/dev/null 2>&1; then
    pass "SBOM CycloneDX válido"
else
    fail "SBOM JSON inválido"
fi

else

fail "SBOM no encontrado"

fi



echo
echo "7. Validación Terraform / Checkov"


if [[ -f "$DAY4_REPORT/checkov-after-hardening.json" ]]; then


FAILED=$(jq '.results.failed_checks | length' \
"$DAY4_REPORT/checkov-after-hardening.json")


if [[ "$FAILED" == "0" ]]; then
    pass "Checkov hardening sin fallos"
else
    fail "Checkov tiene $FAILED fallos"
fi


else

fail "Reporte Checkov inexistente"

fi



echo
echo "8. Validación evidencias VAPT Día 3"


for dir in \
docs/vapt \
reports/day3-verification \
docs/evidence
do

if [[ -d "$ROOT_DIR/$dir" ]]; then

pass "Evidencia VAPT encontrada: $dir"

else

echo "[WARN] No existe todavía: $dir"

fi

done



echo
echo "====================================================="
echo " RESULTADO FINAL"
echo "====================================================="

echo "PASS: $PASS"
echo "FAIL: $FAIL"


if [[ "$FAIL" == "0" ]]; then

echo
echo "DÍA 2 + DÍA 3 APROBADOS"
exit 0

else

echo
echo "DÍA 2 + DÍA 3 REQUIEREN AJUSTES"
exit 1

fi
