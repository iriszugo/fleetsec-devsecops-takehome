#!/usr/bin/env bash

set -euo pipefail

gitleaks_check() {

    local SOURCE_DIR="$1"
    local REPORT_FILE="$2"

    mkdir -p "$(dirname "$REPORT_FILE")"

    gitleaks detect \
        --source "$SOURCE_DIR" \
        --no-banner \
        --redact \
        --report-format json \
        --report-path "$REPORT_FILE" \
        >"${REPORT_FILE}.log" 2>&1 || true

    if [[ ! -f "$REPORT_FILE" ]]; then
        echo "[FAIL] Gitleaks no generó reporte"
        echo "----- Gitleaks debug -----"
        cat "${REPORT_FILE}.log" || true
        return 1
    fi

    local FINDINGS

    FINDINGS=$(jq 'length' "$REPORT_FILE" 2>/dev/null || echo "unknown")

    if [[ "$FINDINGS" == "0" ]]; then
        echo "[PASS] Gitleaks: cero secretos"
        return 0
    else
        echo "[FAIL] Gitleaks detectó posibles secretos ($FINDINGS hallazgos)"
        return 1
    fi
}
