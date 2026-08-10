#!/usr/bin/env bash

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
PARTIAL=0
FAIL=0

echo "======================================================"
echo " FLEETSEC — AUDITORÍA FINAL VAPT"
echo "======================================================"

for f in docs/vapt/*.md; do

    name="$(basename "$f")"

    echo
    echo "------------------------------------------------------"
    echo "$name"
    echo "------------------------------------------------------"

    score=0

    grep -qi "CWE" "$f" && {
        echo "[PASS] CWE"
        score=$((score+1))
    } || echo "[FAIL] CWE"

    grep -qi "OWASP" "$f" && {
        echo "[PASS] OWASP"
        score=$((score+1))
    } || echo "[FAIL] OWASP"

    grep -qiE "Severity|CVSS" "$f" && {
        echo "[PASS] Severity/CVSS"
        score=$((score+1))
    } || echo "[FAIL] Severity/CVSS"

    grep -qiE "PoC|Proof|payload|vulnerable|attack" "$f" && {
        echo "[PASS] PoC/Evidencia"
        score=$((score+1))
    } || echo "[PARTIAL] PoC/Evidencia"

    grep -qiE "Mitigation|Remediation|Mitigated" "$f" && {
        echo "[PASS] Remediación"
        score=$((score+1))
    } || echo "[FAIL] Remediación"

    grep -qiE "reject|rejected|403|401|400|redact|fails|absent|weak" "$f" && {
        echo "[PASS] Flujo malicioso rechazado"
        score=$((score+1))
    } || echo "[PARTIAL] Rechazo malicioso no explícito"

    grep -qiE "legitimate|valid|successful|preserves|accepts|OK|200" "$f" && {
        echo "[PASS] Flujo legítimo"
        score=$((score+1))
    } || echo "[PARTIAL] Flujo legítimo no explícito"

    if [[ "$score" -ge 6 ]]; then
        echo "[RESULT] PASS ($score/7)"
        PASS=$((PASS+1))
    elif [[ "$score" -ge 4 ]]; then
        echo "[RESULT] PARTIAL ($score/7)"
        PARTIAL=$((PARTIAL+1))
    else
        echo "[RESULT] FAIL ($score/7)"
        FAIL=$((FAIL+1))
    fi

done

echo
echo "======================================================"
echo " RESULTADO VAPT"
echo "======================================================"

echo "PASS:    $PASS"
echo "PARTIAL: $PARTIAL"
echo "FAIL:    $FAIL"

if [[ "$PASS" -ge 8 ]]; then
    echo
    echo "ESTADO: VAPT CUMPLE MINIMO DE REMEDIACIONES"
    exit 0
else
    echo
    echo "ESTADO: VAPT REQUIERE CIERRE ADICIONAL"
    exit 1
fi
