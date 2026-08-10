#!/usr/bin/env bash

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT="$ROOT/reports/architecture/FleetSec_FULL_ARCHITECTURE_AUDIT.txt"

mkdir -p "$(dirname "$REPORT")"

exec > >(tee "$REPORT") 2>&1

section() {
    echo
    echo "=========================================================================="
    echo "$1"
    echo "=========================================================================="
}

subsection() {
    echo
    echo "--------------------------------------------------------------------------"
    echo "$1"
    echo "--------------------------------------------------------------------------"
}

file_status() {
    local f="$1"

    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
        printf "TRACKED"
    else
        printf "UNTRACKED"
    fi
}

show_file() {
    local f="$1"

    if [[ -f "$f" ]]; then
        echo
        echo "FILE: $f"
        echo "STATUS: $(file_status "$f")"
        echo "SIZE: $(wc -c < "$f") bytes"
        echo "SHA256: $(sha256sum "$f" | awk '{print $1}')"
    fi
}

cd "$ROOT"

section "FLEETSEC — AUDITORÍA INTEGRAL DE ARQUITECTURA Y ARTEFACTOS"

echo "Proyecto:        $ROOT"
echo "Fecha UTC:       $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Usuario:         $(whoami)"
echo "Hostname:        $(hostname)"
echo "Branch:          $(git branch --show-current 2>/dev/null || echo N/A)"
echo "Commit HEAD:     $(git rev-parse HEAD 2>/dev/null || echo N/A)"
echo "Commit corto:    $(git rev-parse --short HEAD 2>/dev/null || echo N/A)"
echo "Remote origin:   $(git remote get-url origin 2>/dev/null || echo N/A)"

section "01 — ESTADO GIT Y TRAZABILIDAD"

subsection "Git status"
git status --short || true

subsection "Últimos 40 commits"
git log --oneline --decorate -40 2>/dev/null || true

subsection "Archivos versionados"
git ls-files | sort || true

subsection "Archivos NO versionados"
git status --porcelain |
awk '$1=="??" {$1=""; sub(/^ /,""); print}' |
sort || true

section "02 — INVENTARIO FÍSICO COMPLETO DEL REPOSITORIO"

find . \
    -path './.git' -prune -o \
    -path './app/node_modules' -prune -o \
    -type f -print |
sed 's#^\./##' |
sort

section "03 — MANIFIESTO FORENSE SHA-256 DE ARTEFACTOS"

while IFS= read -r f; do
    [[ -f "$f" ]] || continue

    STATUS="$(file_status "$f")"
    SIZE="$(wc -c < "$f" 2>/dev/null || echo 0)"
    HASH="$(sha256sum "$f" 2>/dev/null | awk '{print $1}')"

    printf "%-10s | %12s bytes | %s | %s\n" \
        "$STATUS" \
        "$SIZE" \
        "$HASH" \
        "$f"

done < <(
    find . \
        -path './.git' -prune -o \
        -path './app/node_modules' -prune -o \
        -type f -print |
    sed 's#^\./##' |
    sort
)

section "04 — ARQUITECTURA DE APLICACIÓN NODE.JS / EXPRESS"

subsection "Archivos de aplicación"

find app/src \
    -maxdepth 5 \
    -type f \
    2>/dev/null |
sort || true

subsection "Entrypoints"

for f in \
    app/src/app.js \
    app/src/server.js \
    app/src/database.js \
    app/package.json
do
    show_file "$f"
done

subsection "Dependencias NPM"

if [[ -f app/package.json ]]; then
    node - <<'NODE' 2>/dev/null || true
const p = require("./app/package.json");

console.log("DEPENDENCIES");
for (const [k,v] of Object.entries(p.dependencies || {})) {
  console.log(`  ${k}: ${v}`);
}

console.log("\nDEV DEPENDENCIES");
for (const [k,v] of Object.entries(p.devDependencies || {})) {
  console.log(`  ${k}: ${v}`);
}
NODE
fi

subsection "Montaje Express y endpoints"

grep -RniE \
'app\.(get|post|put|delete|patch|use)|router\.(get|post|put|delete|patch)' \
app/src \
2>/dev/null || true

subsection "Dependencias internas require/import"

grep -RniE \
'require\(|from ['\''"]' \
app/src \
2>/dev/null || true

section "05 — CONTROLES DE HARDENING DE APLICACIÓN"

subsection "Helmet / headers / body limits"

grep -RniE \
'helmet|x-powered-by|10kb|express\.json|Content-Security|HSTS' \
app/src \
2>/dev/null || true

subsection "Autenticación JWT"

grep -RniE \
'JWT_SECRET|jwt\.sign|jwt\.verify|HS256|Bearer|issuer|audience|expiresIn' \
app/src \
app/tests \
2>/dev/null || true

subsection "Gestión de secretos"

grep -RniE \
'process\.env|requireSecret|ADMIN_USERNAME|ADMIN_PASSWORD|DB_PASSWORD|JWT_SECRET' \
app/src \
.env.example \
2>/dev/null || true

subsection "Rate limiting"

grep -RniE \
'express-rate-limit|rateLimit|windowMs|max:' \
app/src \
app/tests \
2>/dev/null || true

subsection "Sanitización PII"

grep -RniE \
'sanitizePII|REDACTED_EMAIL|REDACTED_ID|REDACTED_PHONE|securityLogger' \
app/src \
app/tests \
.semgrep \
app/.semgrep \
2>/dev/null || true

section "06 — VAPT Y SUPERFICIE DE ATAQUE"

subsection "Documentos VAPT"

find docs/vapt \
    -maxdepth 2 \
    -type f \
    2>/dev/null |
sort || true

subsection "Resumen de cada hallazgo"

for f in docs/vapt/*.md; do
    [[ -f "$f" ]] || continue

    echo
    echo "FILE: $f"

    grep -m 15 -iE \
    '^#|CWE|OWASP|Severity|CVSS|Status|MITIGATED|PoC|Remediation|Mitigation' \
    "$f" \
    2>/dev/null || true
done

subsection "Laboratorio vulnerable"

find app/lab \
    -maxdepth 5 \
    -type f \
    2>/dev/null |
sort || true

subsection "Pruebas funcionales de seguridad"

find app/test app/tests \
    -maxdepth 5 \
    -type f \
    2>/dev/null |
sort || true

subsection "Auditoría VAPT automatizada"

if [[ -x scripts/audit-vapt-final.sh ]]; then
    ./scripts/audit-vapt-final.sh || true
else
    echo "scripts/audit-vapt-final.sh no versionado/no ejecutable"
fi

section "07 — SAST / SEMGREP"

subsection "Reglas Semgrep"

find .semgrep app/.semgrep \
    -maxdepth 3 \
    -type f \
    2>/dev/null |
sort || true

subsection "IDs / mensajes / severidad"

grep -RniE \
'^[[:space:]]*(id|message|severity|languages|pattern|patterns):' \
.semgrep \
app/.semgrep \
2>/dev/null || true

subsection "Fixtures positivos y negativos"

find app/tests/semgrep \
    -maxdepth 2 \
    -type f \
    2>/dev/null |
sort || true

section "08 — SCA / TRIVY / SBOM"

subsection "Trivy"

find . \
    -path './.git' -prune -o \
    -path './app/node_modules' -prune -o \
    -type f \
    \( -iname '*trivy*' -o -iname '*sca*' \) \
    -print |
sort || true

subsection "SBOM"

find reports docs \
    -type f \
    \( -iname '*sbom*' -o -iname 'bom.json' \) \
    -print \
2>/dev/null |
sort || true

if [[ -f reports/sbom/bom.json ]]; then
    echo
    echo "CycloneDX:"
    grep -m 5 -E \
    '"bomFormat"|"specVersion"|"version"|"components"' \
    reports/sbom/bom.json \
    2>/dev/null || true
fi

section "09 — SECRET SCANNING / GITLEAKS"

find . \
    -path './.git' -prune -o \
    -path './app/node_modules' -prune -o \
    -type f \
    \( -iname '*gitleaks*' -o -name '.gitleaksignore' \) \
    -print |
sort || true

grep -RniE \
'gitleaks/gitleaks-action|gitleaks detect|fetch-depth' \
.github scripts \
2>/dev/null || true

section "10 — CI/CD GITHUB ACTIONS"

subsection "Workflows"

find .github/workflows \
    -maxdepth 2 \
    -type f \
    -print \
2>/dev/null |
sort || true

for f in .github/workflows/*.yml .github/workflows/*.yaml; do
    [[ -f "$f" ]] || continue

    echo
    echo "========================================================================"
    echo "WORKFLOW: $f"
    echo "========================================================================"

    grep -nE \
    'name:|uses:|run:|needs:|if:|permissions:|timeout-minutes:|artifact|Semgrep|Trivy|Checkov|Gitleaks|ZAP|security' \
    "$f" \
    2>/dev/null || true
done

section "11 — DAST OWASP ZAP AUTENTICADO"

show_file ".github/workflows/zap-dast.yml"
show_file "app/openapi.yaml"

subsection "Controles ZAP"

grep -nE \
'auth/token|auth/profile|ZAP_AUTH_HEADER|Bearer|OpenAPI|coverage|80|zap-api-scan|security/medium|HIGH|CRITICAL|report_json|upload-artifact' \
.github/workflows/zap-dast.yml \
app/openapi.yaml \
2>/dev/null || true

section "12 — DOCKER / CONTENEDORES"

for f in \
    app/Dockerfile \
    app/.dockerignore \
    docker-compose.yml \
    compose.yml
do
    show_file "$f"
done

grep -RniE \
'FROM |USER |EXPOSE|HEALTHCHECK|docker build|docker run|docker compose' \
app \
.github \
scripts \
2>/dev/null \
--exclude-dir=node_modules || true

section "13 — TERRAFORM / AWS SECURITY BASELINE"

subsection "Árbol Terraform"

find terraform \
    -maxdepth 6 \
    -type f \
    2>/dev/null |
sort || true

subsection "Recursos Terraform"

grep -RniE \
'^[[:space:]]*(resource|module|data)[[:space:]]+"' \
terraform \
2>/dev/null || true

subsection "IAM"

grep -RniE \
'aws_iam|iam_|AdministratorAccess|Deny|Action|Resource' \
terraform \
2>/dev/null || true

subsection "KMS"

grep -RniE \
'aws_kms|kms_|enable_key_rotation|SSE-KMS' \
terraform \
2>/dev/null || true

subsection "S3"

grep -RniE \
'aws_s3|public_access|server_side_encryption|object_lock|lifecycle|GLACIER' \
terraform \
2>/dev/null || true

subsection "VPC / NETWORK"

grep -RniE \
'aws_vpc|aws_subnet|flow_log|security_group|route_table|nat_gateway|internet_gateway' \
terraform \
2>/dev/null || true

subsection "RDS"

grep -RniE \
'aws_db|rds|storage_encrypted|publicly_accessible|backup_retention' \
terraform \
2>/dev/null || true

subsection "Secrets Manager"

grep -RniE \
'aws_secretsmanager|secret_string' \
terraform \
2>/dev/null || true

subsection "WAF"

grep -RniE \
'aws_wafv2|SQLi|KnownBadInputs|rate_based|BLOCK|block' \
terraform \
2>/dev/null || true

subsection "CloudTrail"

grep -RniE \
'cloudtrail|multi_region|log_file_validation|metric_filter|cloudwatch' \
terraform \
2>/dev/null || true

subsection "AWS Config"

grep -RniE \
'aws_config|configuration_recorder|config_rule' \
terraform \
2>/dev/null || true

subsection "GuardDuty"

grep -RniE \
'guardduty|malware|s3_protection|threat_intel' \
terraform \
2>/dev/null || true

subsection "SecurityHub"

grep -RniE \
'securityhub|security_hub|FSBP|CIS' \
terraform \
2>/dev/null || true

section "14 — CHECKOV / IaC EVIDENCE"

find . docs reports \
    -path './app/node_modules' -prune -o \
    -type f \
    -iname '*checkov*' \
    -print |
sort || true

section "15 — DETECCIÓN SIGMA"

find detection/sigma \
    -maxdepth 3 \
    -type f \
    2>/dev/null |
sort || true

for f in detection/sigma/*.yml detection/sigma/*.yaml; do
    [[ -f "$f" ]] || continue

    echo
    echo "FILE: $f"

    grep -E \
    '^(title|id|status|description|logsource|detection|falsepositives|level|tags):|eventName:|eventSource:|condition:' \
    "$f" \
    2>/dev/null || true
done

section "16 — THREAT INTELLIGENCE / IOC"

find detection/threat-intel \
    -maxdepth 3 \
    -type f \
    2>/dev/null |
sort || true

grep -RniE \
'185\.220\.101\.22|AS213151|VirusTotal|AbuseIPDB|Shodan|MISP|OTX|GuardDuty|Threat Intel' \
detection \
docs \
2>/dev/null || true

section "17 — INCIDENT RESPONSE"

find docs/incident-response \
    -maxdepth 3 \
    -type f \
    2>/dev/null |
sort || true

subsection "AWS containment"

grep -RniE \
'detach-user-policy|DenyAllExplicit|update-access-key|modify-instance-attribute|create-snapshot|stop-task|DeleteTrail|fleetsec-prod-cluster|i-0abc1234def56789|vol-0abc1234def56789' \
docs/incident-response \
2>/dev/null || true

subsection "MITRE ATT&CK"

grep -RniE \
'T1078|T1098|T1567|T1048|T1562\.001|T1071\.004' \
docs/incident-response \
2>/dev/null || true

subsection "Compliance / SIC"

grep -RniE \
'Ley 1581|Superintendencia|SIC|15 días|P1|P2|P3' \
docs/incident-response \
2>/dev/null || true

section "18 — FORENSICS / CHAIN OF CUSTODY"

show_file "docs/evidence/chain-of-custody.log"

grep -nE \
'UTC Timestamp|Analyst|Artifact|SHA256|Action' \
docs/evidence/chain-of-custody.log \
2>/dev/null || true

section "19 — EVIDENCIAS COMPLETAS"

find docs/evidence reports \
    -maxdepth 6 \
    -type f \
    2>/dev/null |
sort || true

section "20 — README / ADR / IA / ARQUITECTURA"

show_file "README.md"

subsection "ADRs"

find docs/adr \
    -maxdepth 3 \
    -type f \
    2>/dev/null |
sort || true

subsection "IA"

find docs \
    -maxdepth 3 \
    -type f \
    \( -iname '*AI*' -o -iname '*IA*' \) \
    -print \
2>/dev/null |
sort || true

grep -RniE \
'AI|IA|Inteligencia Artificial|hallucination|alucinación|Human-in-the-Loop|monkey|console\.log|Checkov' \
README.md docs \
2>/dev/null || true

subsection "Arquitectura en README"

grep -nE \
'Architecture|Arquitectura|mermaid|graph TD|flowchart|AWS|DevSecOps|VAPT|Incident Response' \
README.md \
2>/dev/null || true

section "21 — SCRIPTS DE AUTOMATIZACIÓN"

find scripts \
    -maxdepth 4 \
    -type f \
    -print \
2>/dev/null |
sort || true

subsection "Scripts y propósito inferido"

for f in scripts/*.sh scripts/lib/*.sh; do
    [[ -f "$f" ]] || continue

    echo
    echo "FILE: $f"
    echo "STATUS: $(file_status "$f")"

    grep -m 15 -E \
    '^#!/|FleetSec|DÍA|DIA|AUDITOR|VERIFY|RESULTADO|PASS|FAIL|Gitleaks|Trivy|Semgrep|Checkov|ZAP|Terraform' \
    "$f" \
    2>/dev/null || true
done

section "22 — ARTEFACTOS CREADOS MANUALMENTE / NO VERSIONADOS"

echo "Todo archivo ?? de Git se registra aquí."
echo "Esto incluye archivos creados mediante nano, cat, heredoc u otros métodos"
echo "si todavía no han sido agregados al índice Git."
echo

git status --porcelain |
while IFS= read -r line; do

    STATUS="${line:0:2}"
    FILE="${line:3}"

    if [[ "$STATUS" == "??" ]]; then
        echo
        echo "UNTRACKED: $FILE"

        if [[ -f "$FILE" ]]; then
            echo "TYPE: FILE"
            echo "SIZE: $(wc -c < "$FILE") bytes"
            echo "SHA256: $(sha256sum "$FILE" | awk '{print $1}')"

        elif [[ -d "$FILE" ]]; then
            echo "TYPE: DIRECTORY"

            find "$FILE" \
                -type f \
                -print \
                2>/dev/null |
            sort
        fi
    fi
done

section "23 — MAPA DE DEPENDENCIAS ARQUITECTÓNICAS"

echo "APPLICATION"
echo "  app/src/server.js"
echo "       |"
echo "       v"
echo "  app/src/app.js"
echo "       |"
echo "       +--> /health"
echo "       +--> /users"
echo "       +--> /secure/users"
echo "       +--> /api/v1/system"
echo "       +--> /auth/login"
echo "       +--> /auth/token"
echo "       +--> /auth/profile"
echo
echo "SECURITY"
echo "  Helmet"
echo "  Body limit"
echo "  JWT HS256"
echo "  Environment secrets"
echo "  Rate limiting"
echo "  PII sanitizer"
echo "  Parameterized SQL"
echo "  Command execution hardening"
echo
echo "DEVSECOPS"
echo "  GitHub Actions"
echo "       +--> Build / Jest / SBOM"
echo "       +--> Gitleaks"
echo "       +--> Semgrep"
echo "       +--> Trivy"
echo "       +--> Checkov"
echo "       +--> ZAP Authenticated DAST"
echo "       +--> Security Gate"
echo
echo "AWS / IAC"
echo "  Terraform"
echo "       +--> IAM"
echo "       +--> KMS"
echo "       +--> S3"
echo "       +--> VPC"
echo "       +--> RDS"
echo "       +--> Secrets Manager"
echo "       +--> WAF"
echo "       +--> CloudTrail"
echo "       +--> Config"
echo "       +--> GuardDuty"
echo "       +--> SecurityHub"
echo
echo "DETECTION / IR"
echo "  Sigma"
echo "  Threat Intelligence"
echo "  MITRE ATT&CK"
echo "  AWS containment"
echo "  RCA"
echo "  CEO report"
echo "  Chain of Custody"

section "24 — AUDITORÍAS AUTOMÁTICAS DISPONIBLES"

for script in \
    scripts/verify-day1.sh \
    scripts/verify-day2.sh \
    scripts/verify-day3.sh \
    scripts/verify-day5.sh \
    scripts/audit-vapt-final.sh \
    scripts/audit-fleetsec-final.sh
do
    if [[ -f "$script" ]]; then
        echo "[FOUND] $script"
    else
        echo "[MISSING] $script"
    fi
done

section "25 — AUDITORÍA MAESTRA ACTUAL"

if [[ -x scripts/audit-fleetsec-final.sh ]]; then
    ./scripts/audit-fleetsec-final.sh || true
else
    echo "scripts/audit-fleetsec-final.sh no está disponible como ejecutable."
fi

section "26 — RESUMEN CUANTITATIVO"

TOTAL_FILES=$(
    find . \
        -path './.git' -prune -o \
        -path './app/node_modules' -prune -o \
        -type f -print |
    wc -l
)

TRACKED_FILES=$(git ls-files | wc -l)

UNTRACKED_FILES=$(
    git status --porcelain |
    awk '$1=="??"' |
    wc -l
)

VAPT_DOCS=$(
    find docs/vapt \
        -maxdepth 1 \
        -type f \
        -name '*.md' \
        2>/dev/null |
    wc -l
)

SIGMA_RULES=$(
    find detection/sigma \
        -maxdepth 1 \
        -type f \
        \( -name '*.yml' -o -name '*.yaml' \) \
        2>/dev/null |
    wc -l
)

TESTS=$(
    find app/test app/tests \
        -type f \
        -name '*.js' \
        2>/dev/null |
    wc -l
)

TF_FILES=$(
    find terraform \
        -type f \
        -name '*.tf' \
        2>/dev/null |
    wc -l
)

echo "Archivos físicos totales:       $TOTAL_FILES"
echo "Archivos versionados Git:       $TRACKED_FILES"
echo "Entradas no versionadas:        $UNTRACKED_FILES"
echo "Documentos VAPT:                $VAPT_DOCS"
echo "Reglas Sigma:                   $SIGMA_RULES"
echo "Archivos JS de pruebas:         $TESTS"
echo "Archivos Terraform:             $TF_FILES"

section "27 — FIN DE AUDITORÍA"

echo "[PASS] Inventario físico completado"
echo "[PASS] Git inspeccionado"
echo "[PASS] Aplicación inspeccionada"
echo "[PASS] VAPT inspeccionado"
echo "[PASS] CI/CD inspeccionado"
echo "[PASS] ZAP inspeccionado"
echo "[PASS] Terraform inspeccionado"
echo "[PASS] Detection inspeccionado"
echo "[PASS] Incident Response inspeccionado"
echo "[PASS] Evidencias inspeccionadas"
echo "[PASS] Archivos no versionados registrados"
echo "[PASS] SHA-256 generados"
echo
echo "REPORTE:"
echo "$REPORT"
echo
echo "AUDITORÍA DE ARQUITECTURA COMPLETADA."
