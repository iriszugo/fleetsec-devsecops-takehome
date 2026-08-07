#!/usr/bin/env bash

set -uo pipefail

PASS=0
FAIL=0

echo "======================================"
echo " FleetSec — Verificación Día 5 IR"
echo "======================================"

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}


check_file() {

    if [[ -f "$1" ]]; then
        pass "$2"
    else
        fail "$2"
    fi

}


echo
echo "1. Validación artefactos Incident Response"

check_file \
"docs/incident-response/IR-PLAYBOOK-T0200.md" \
"Playbook AWS Containment existe"

check_file \
"docs/incident-response/MITRE-ATTACK-MAP.md" \
"MITRE ATT&CK Mapping existe"

check_file \
"docs/incident-response/RCA-INCIDENT-2026.md" \
"Root Cause Analysis existe"

check_file \
"docs/incident-response/CEO-EXECUTIVE-REPORT.md" \
"CEO Executive Report existe"

check_file \
"docs/evidence/chain-of-custody.log" \
"Chain of Custody existe"


echo
echo "2. Validación integridad SHA256"


HASH_ERRORS=0

while read -r artifact hash; do

    if [[ -f "$artifact" ]]; then

        CURRENT=$(sha256sum "$artifact" | awk '{print $1}')

        if [[ "$CURRENT" == "$hash" ]]; then
            :
        else
            HASH_ERRORS=$((HASH_ERRORS+1))
        fi

    fi

done < <(
awk '
/Artifact:/ {
    getline;
    artifact=$0
}
/SHA256:/ {
    getline;
    hash=$0
    print artifact,hash
}
' docs/evidence/chain-of-custody.log
)


if [[ "$HASH_ERRORS" -eq 0 ]]; then
    pass "Hash SHA256 válido"
else
    fail "Hash SHA256 inválido ($HASH_ERRORS errores)"
fi


echo
echo "======================================"
echo " RESULTADO FINAL"
echo "======================================"

echo "PASS: $PASS"
echo "FAIL: $FAIL"


if [[ "$FAIL" -eq 0 ]]; then
    echo
    echo "DÍA 5 INCIDENT RESPONSE APROBADO"
    exit 0
else
    echo
    echo "DÍA 5 INCIDENT RESPONSE FALLIDO"
    exit 1
fi
