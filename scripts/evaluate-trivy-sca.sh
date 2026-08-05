#!/usr/bin/env bash

set -euo pipefail

REPORT="${1:-trivy-results.json}"
PACKAGE_JSON="${2:-app/package.json}"

DIRECT_THRESHOLD="8.0"
TRANSITIVE_THRESHOLD="9.0"
BLOCKING=0

echo "========================================="
echo " FleetSec Trivy SCA Quality Gate"
echo "========================================="
echo "Report: $REPORT"
echo

if [[ ! -f "$REPORT" ]]; then
    echo "ERROR: Trivy report not found: $REPORT"
    exit 1
fi

if [[ ! -f "$PACKAGE_JSON" ]]; then
    echo "ERROR: package.json not found: $PACKAGE_JSON"
    exit 1
fi

DIRECT_DEPENDENCIES="$(
    jq -r '
        ((.dependencies // {}) + (.devDependencies // {}))
        | keys[]
    ' "$PACKAGE_JSON"
)"

while IFS= read -r VULN; do
    ID="$(jq -r '.VulnerabilityID // "UNKNOWN"' <<< "$VULN")"
    PACKAGE="$(jq -r '.PkgName // "UNKNOWN"' <<< "$VULN")"
    SEVERITY="$(jq -r '.Severity // "UNKNOWN"' <<< "$VULN")"

    SCORE="$(
        jq -r '
            [
                .CVSS[]?.V3Score?,
                .CVSS[]?.V31Score?,
                .CVSS[]?.V30Score?
            ]
            | map(select(. != null))
            | if length > 0 then max else 0 end
        ' <<< "$VULN"
    )"

    RELATION="transitive"
    THRESHOLD="$TRANSITIVE_THRESHOLD"

    if grep -Fxq "$PACKAGE" <<< "$DIRECT_DEPENDENCIES"; then
        RELATION="direct"
        THRESHOLD="$DIRECT_THRESHOLD"
    fi

    if awk -v score="$SCORE" -v limit="$THRESHOLD" \
        'BEGIN { exit !(score >= limit) }'; then

        echo "BLOCKING VULNERABILITY"
        echo "----------------------"
        echo "Package    : $PACKAGE"
        echo "CVE        : $ID"
        echo "Severity   : $SEVERITY"
        echo "CVSS       : $SCORE"
        echo "Dependency : $RELATION"
        echo "Threshold  : $THRESHOLD"
        echo

        BLOCKING=1
    fi

done < <(
    jq -c '
        .Results[]?
        | .Vulnerabilities[]?
    ' "$REPORT"
)

if [[ "$BLOCKING" -eq 1 ]]; then
    echo "Quality Gate FAILED"
    exit 1
fi

echo "Quality Gate PASSED"
exit 0
