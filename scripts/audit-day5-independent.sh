#!/usr/bin/env bash

set -uo pipefail

PASS=0
FAIL=0

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "================================================="
echo " AUDITORÍA INDEPENDIENTE DÍA 5 - INCIDENT RESPONSE"
echo "================================================="
echo "Proyecto: $ROOT"
echo


check_file() {

FILE="$1"
DESC="$2"

if [[ -f "$ROOT/$FILE" ]]; then
    echo "[PASS] $DESC"
    PASS=$((PASS+1))
else
    echo "[FAIL] $DESC"
    FAIL=$((FAIL+1))
fi

}


check_pattern(){

FILE="$1"
PATTERN="$2"
DESC="$3"

if grep -qE "$PATTERN" "$ROOT/$FILE" 2>/dev/null; then
    echo "[PASS] $DESC"
    PASS=$((PASS+1))
else
    echo "[FAIL] $DESC"
    FAIL=$((FAIL+1))
fi

}


echo "--- ARTEFACTOS ---"

check_file \
"docs/incident-response/IR-PLAYBOOK-T0200.md" \
"Playbook AWS Containment"

check_file \
"docs/incident-response/MITRE-ATTACK-MAP.md" \
"MITRE ATT&CK Mapping"

check_file \
"docs/incident-response/RCA-INCIDENT-2026.md" \
"Root Cause Analysis"

check_file \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"CEO Executive Report"

check_file \
"docs/evidence/chain-of-custody.log" \
"Cadena de Custodia Forense"


echo
echo "--- AWS CONTAINMENT ---"


PLAYBOOK="docs/incident-response/IR-PLAYBOOK-T0200.md"


check_pattern \
"$PLAYBOOK" \
"detach-user-policy" \
"IAM revocación AdministratorAccess"


check_pattern \
"$PLAYBOOK" \
"DenyAllExplicit" \
"Explicit Deny IAM"


check_pattern \
"$PLAYBOOK" \
"modify-instance-attribute" \
"EC2 aislamiento cuarentena"


check_pattern \
"$PLAYBOOK" \
"stop-task" \
"ECS Stop Task"


check_pattern \
"$PLAYBOOK" \
"create-snapshot" \
"Snapshot EBS forense"



echo
echo "--- MITRE ---"


MITRE="docs/incident-response/MITRE-ATTACK-MAP.md"

TECHNIQUES=$(grep -oE "T[0-9]{4}(\.[0-9]+)?" "$ROOT/$MITRE" | sort -u | wc -l)

if [[ "$TECHNIQUES" -ge 6 ]]; then
    echo "[PASS] MITRE técnicas identificadas: $TECHNIQUES"
    PASS=$((PASS+1))
else
    echo "[FAIL] MITRE técnicas insuficientes: $TECHNIQUES"
    FAIL=$((FAIL+1))
fi



echo
echo "--- RCA ---"

check_pattern \
"docs/incident-response/RCA-INCIDENT-2026.md" \
"Root|Causa|Vector|IAM" \
"RCA contiene análisis incidente"



echo
echo "--- COMPLIANCE ---"


check_pattern \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"SIC|Superintendencia" \
"Ley 1581 SIC"


check_pattern \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"15 días|15 dias" \
"Plazo regulatorio"


check_pattern \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"P1" \
"Plan P1"


check_pattern \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"P2" \
"Plan P2"


check_pattern \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"P3" \
"Plan P3"



echo
echo "--- FORENSIC ---"


HASHES=$(grep -cE "[a-f0-9]{64}" "$ROOT/docs/evidence/chain-of-custody.log" 2>/dev/null || true)

if [[ "$HASHES" -gt 0 ]]; then
    echo "[PASS] SHA256 evidencias encontradas: $HASHES"
    PASS=$((PASS+1))
else
    echo "[FAIL] No existen hashes SHA256"
    FAIL=$((FAIL+1))
fi



echo
echo "================================================="
echo " RESULTADO FINAL"
echo "================================================="

echo "PASS: $PASS"
echo "FAIL: $FAIL"


if [[ "$FAIL" -eq 0 ]]; then
    echo
    echo "DÍA 5 INCIDENT RESPONSE VALIDADO AL 100%"
    exit 0
else
    echo
    echo "DÍA 5 TIENE HALLAZGOS"
    exit 1
fi
