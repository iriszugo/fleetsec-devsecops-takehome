#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/reports/regression-diagnostics"

mkdir -p "$LOG_DIR"

echo "======================================================"
echo " FleetSec — Diagnóstico de Regresiones"
echo "======================================================"
echo
echo "Fecha UTC: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "PWD: $(pwd)"
echo "ROOT_DIR: $ROOT_DIR"
echo

echo "===== ENTORNO GITHUB / GIT ====="
echo "GITHUB_ACTIONS=${GITHUB_ACTIONS:-<unset>}"
echo "GITHUB_EVENT_NAME=${GITHUB_EVENT_NAME:-<unset>}"
echo "GITHUB_REF=${GITHUB_REF:-<unset>}"
echo "GITHUB_REF_NAME=${GITHUB_REF_NAME:-<unset>}"
echo "GITHUB_HEAD_REF=${GITHUB_HEAD_REF:-<unset>}"
echo "GITHUB_SHA=${GITHUB_SHA:-<unset>}"
echo

echo "git branch --show-current:"
git branch --show-current || true

echo
echo "git symbolic-ref --short HEAD:"
git symbolic-ref --short HEAD 2>&1 || true

echo
echo "git rev-parse --abbrev-ref HEAD:"
git rev-parse --abbrev-ref HEAD 2>&1 || true

echo
echo "git status:"
git status --short || true

echo
echo "===== VERSIONES ====="
node --version 2>&1 || true
npm --version 2>&1 || true
docker --version 2>&1 || true
trivy --version 2>&1 | head -5 || true
semgrep --version 2>&1 || true
gitleaks version 2>&1 || true

run_regression() {
    local day="$1"
    local script="$ROOT_DIR/scripts/verify-${day}.sh"
    local log="$LOG_DIR/${day}.log"

    echo
    echo "======================================================"
    echo " Ejecutando ${day}"
    echo " Log: $log"
    echo "======================================================"

    set +e
    FLEETSEC_REGRESSION_MODE=1 bash -x "$script" >"$log" 2>&1
    local rc=$?
    set -e

    echo "EXIT_CODE_${day}=$rc"

    if [[ "$rc" -eq 0 ]]; then
        echo "[PASS] ${day}"
    else
        echo "[FAIL] ${day}"
    fi

    echo
    echo "----- Hallazgos relevantes ${day} -----"
    grep -nEi \
        '\[FAIL\]|error|fatal|incorrecta|rama|branch|denied|not found|failed|exit code|RESULTADO' \
        "$log" | tail -80 || true

    echo
    echo "----- Últimas 80 líneas ${day} -----"
    tail -80 "$log"

    return "$rc"
}

set +e

run_regression day1
DAY1_RC=$?

run_regression day2
DAY2_RC=$?

set -e

echo
echo "======================================================"
echo " RESUMEN DIAGNÓSTICO"
echo "======================================================"
echo "DAY1_EXIT_CODE=$DAY1_RC"
echo "DAY2_EXIT_CODE=$DAY2_RC"

if [[ "$DAY1_RC" -eq 0 && "$DAY2_RC" -eq 0 ]]; then
    echo "RESULTADO_DIAGNOSTICO=PASS"
    exit 0
else
    echo "RESULTADO_DIAGNOSTICO=FAIL"
    exit 1
fi
