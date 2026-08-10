#!/usr/bin/env bash

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
PARTIAL=0
FAIL=0

pass() {
  echo "[PASS] $1"
  PASS=$((PASS+1))
}

partial() {
  echo "[PARTIAL] $1"
  PARTIAL=$((PARTIAL+1))
}

fail() {
  echo "[FAIL] $1"
  FAIL=$((FAIL+1))
}

exists() {
  [[ -e "$1" ]]
}

contains() {
  grep -qE "$2" "$1" 2>/dev/null
}

echo "============================================================"
echo " FLEETSEC — AUDITORÍA INTEGRAL FINAL READ-ONLY"
echo "============================================================"
echo "ROOT: $ROOT"
echo

echo "=== 01 PIPELINE DEVSECOPS ==="

exists ".github/workflows/devsecops-pipeline.yml" \
  && pass "Pipeline GitHub Actions existe" \
  || fail "Pipeline GitHub Actions faltante"

contains ".github/workflows/devsecops-pipeline.yml" "semgrep|Semgrep" \
  && pass "Semgrep integrado" \
  || fail "Semgrep no detectado"

contains ".github/workflows/devsecops-pipeline.yml" "trivy|Trivy" \
  && pass "Trivy integrado" \
  || fail "Trivy no detectado"

contains ".github/workflows/devsecops-pipeline.yml" "checkov|Checkov" \
  && pass "Checkov integrado" \
  || fail "Checkov no detectado"

contains ".github/workflows/devsecops-pipeline.yml" "gitleaks|Gitleaks" \
  && pass "Gitleaks integrado" \
  || fail "Gitleaks no detectado"

exists "reports/sbom/bom.json" \
  && pass "SBOM CycloneDX existe" \
  || fail "SBOM faltante"

if exists ".github/workflows/zap-dast.yml"; then
  ZAP_FILE=".github/workflows/zap-dast.yml"

  ZAP_OK=true

  grep -q "zap-api-scan.py" "$ZAP_FILE" || ZAP_OK=false
  grep -q "ZAP_AUTH_HEADER_VALUE" "$ZAP_FILE" || ZAP_OK=false
  grep -q "Bearer" "$ZAP_FILE" || ZAP_OK=false
  grep -q "OpenAPI coverage gate >= 80%" "$ZAP_FILE" || ZAP_OK=false
  grep -q "security/medium" "$ZAP_FILE" || ZAP_OK=false
  grep -q "HIGH/CRITICAL" "$ZAP_FILE" || ZAP_OK=false
  grep -q "report_json.json" "$ZAP_FILE" || ZAP_OK=false

  if [[ "$ZAP_OK" == "true" ]]; then
    pass "ZAP autenticado + JWT + OpenAPI >=80% + gates configurados"
  else
    partial "Workflow ZAP existe pero faltan controles requeridos"
  fi
else
  fail "DAST ZAP faltante"
fi

if exists ".github/CODEOWNERS"; then
  OWNERS=$(grep -vE '^\s*(#|$)' .github/CODEOWNERS | grep -o '@[^[:space:]]*' | sort -u | wc -l)
  if [[ "$OWNERS" -ge 2 ]]; then
    pass "CODEOWNERS contiene al menos 2 propietarios"
  else
    partial "CODEOWNERS existe pero no demuestra 2 aprobadores"
  fi
else
  fail "CODEOWNERS faltante"
fi

echo
echo "=== 02 VAPT + REMEDIACIÓN ==="

VAPT_COUNT=0

for id in 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010; do
  if find docs/vapt -type f 2>/dev/null | grep -q "$id"; then
    VAPT_COUNT=$((VAPT_COUNT+1))
  fi
done

if [[ "$VAPT_COUNT" -ge 7 ]]; then
  pass "Documentación VAPT detectada para >=7 hallazgos ($VAPT_COUNT)"
else
  partial "Solo se detectaron $VAPT_COUNT/10 documentos VAPT"
fi

if find app/tests app/test -type f 2>/dev/null | grep -q .; then
  pass "Pruebas de seguridad existentes"
else
  fail "No se detectaron pruebas de seguridad"
fi

contains "app/src/routes/auth.js" "JWT_SECRET|process\.env" \
  && pass "V-10 usa variables de entorno en autenticación" \
  || partial "V-10 requiere validación"

if exists "app/src/utils/piiSanitizer.js"; then
  pass "V-08 sanitizer PII existe"
else
  partial "V-08 sanitizer PII no encontrado"
fi

echo
echo "=== 03 AWS IAC TERRAFORM ==="

exists "terraform/modules/security-baseline" \
  && pass "Módulo security-baseline existe" \
  || fail "Módulo Terraform faltante"

for f in iam.tf kms.tf s3.tf vpc.tf rds.tf secrets.tf waf.tf; do
  exists "terraform/modules/security-baseline/$f" \
    && pass "Terraform $f" \
    || partial "Terraform $f faltante"
done

if find reports docs/evidence -type f 2>/dev/null | grep -qi "checkov"; then
  pass "Evidencia Checkov encontrada"
else
  fail "Evidencia Checkov faltante"
fi

grep -Rqi "cloudtrail" terraform/modules/security-baseline \
  && pass "CloudTrail detectado" \
  || partial "CloudTrail no detectado"

grep -Rqi "guardduty" terraform/modules/security-baseline \
  && pass "GuardDuty detectado" \
  || partial "GuardDuty no detectado"

grep -Rqi "securityhub\|security_hub" terraform/modules/security-baseline \
  && pass "SecurityHub detectado" \
  || partial "SecurityHub no detectado"

grep -Rqi "aws_config\|config_configuration_recorder" terraform/modules/security-baseline \
  && pass "AWS Config detectado" \
  || partial "AWS Config no detectado"

echo
echo "=== 04 DETECCIÓN + INCIDENT RESPONSE ==="

for f in \
  docs/incident-response/IR-PLAYBOOK-T0200.md \
  docs/incident-response/MITRE-ATTACK-MAP.md \
  docs/incident-response/RCA-INCIDENT-2026.md \
  docs/incident-response/CEO-EXECUTIVE-REPORT.md \
  docs/evidence/chain-of-custody.log
do
  exists "$f" && pass "$f" || fail "$f"
done

SIGMA_COUNT=$(find detection -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l)

if [[ "$SIGMA_COUNT" -ge 3 ]]; then
  pass "Sigma YAML >=3 ($SIGMA_COUNT)"
else
  fail "Sigma YAML insuficiente ($SIGMA_COUNT/3)"
fi

if find detection docs -type f 2>/dev/null | xargs grep -li "185\.220\.101\.22" 2>/dev/null | grep -q .; then
  pass "IOC 185.220.101.22 documentado"
else
  fail "IOC principal no documentado"
fi

if find detection -type f 2>/dev/null | grep -Ei "threat.*intel|intel.*set" | grep -q .; then
  pass "Threat Intel artifact detectado"
else
  fail "Threat Intel Set faltante"
fi

echo
echo "=== 05 DOCUMENTACIÓN / ENTREGA ==="

exists "README.md" && pass "README existe" || fail "README faltante"

ADR_COUNT=$(find docs/adr -type f 2>/dev/null | wc -l)
if [[ "$ADR_COUNT" -ge 1 ]]; then
  pass "ADR detectados ($ADR_COUNT)"
else
  fail "ADRs faltantes"
fi

if grep -qiE "mermaid|architecture|arquitectura" README.md 2>/dev/null; then
  pass "Arquitectura referenciada en README"
else
  partial "Arquitectura final no comprobada en README"
fi

if grep -qiE "IA|AI|Inteligencia Artificial" README.md 2>/dev/null; then
  pass "Reporte de IA referenciado en README"
else
  fail "Reporte de IA faltante en README"
fi

if find reports docs -type f 2>/dev/null | grep -Ei "VAPT.*\.pdf|\.pdf.*VAPT" | grep -q .; then
  pass "VAPT PDF detectado"
else
  fail "VAPT PDF faltante"
fi

if grep -qiE "youtube|youtu\.be|video" README.md 2>/dev/null; then
  pass "Enlace/referencia de video detectado"
else
  partial "Video de sustentación aún no referenciado"
fi

echo
echo "============================================================"
echo " RESULTADO AUDITORÍA"
echo "============================================================"
echo "PASS:    $PASS"
echo "PARTIAL: $PARTIAL"
echo "FAIL:    $FAIL"
echo

if [[ "$FAIL" -eq 0 && "$PARTIAL" -eq 0 ]]; then
  echo "ESTADO: READY FOR FINAL DELIVERY"
  exit 0
elif [[ "$FAIL" -eq 0 ]]; then
  echo "ESTADO: READY WITH PENDING VALIDATIONS"
  exit 2
else
  echo "ESTADO: REMEDIATION REQUIRED"
  exit 1
fi
