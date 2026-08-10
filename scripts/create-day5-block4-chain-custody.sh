#!/usr/bin/env bash

set -euo pipefail

DIR="docs/evidence"
FILE="$DIR/chain-of-custody.log"

mkdir -p "$DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ANALYST="Iris Patricia Zúñiga Gómez"

cat > "$FILE" <<EOF
====================================================
CHAIN OF CUSTODY LOG
Incident: INC-2026-001
====================================================

UTC Timestamp:
$TIMESTAMP

Analyst:
$ANALYST

Purpose:
Registro de integridad criptográfica de evidencias
generadas durante respuesta a incidente AWS.

====================================================

EOF


# Registrar evidencias disponibles

for ARTIFACT in \
docs/incident-response/IR-PLAYBOOK-T0200.md \
docs/incident-response/MITRE-ATTACK-MAP.md \
docs/incident-response/RCA-INCIDENT-2026.md \
docs/incident-response/CEO-EXECUTIVE-REPORT.md
do

    if [[ -f "$ARTIFACT" ]]; then

        HASH=$(sha256sum "$ARTIFACT" | awk '{print $1}')

        cat >> "$FILE" <<EOF

UTC Timestamp:
$TIMESTAMP

Analyst:
$ANALYST

Artifact:
$ARTIFACT

SHA256:
$HASH

Action:
Evidence integrity hash generated and recorded.

----------------------------------------------------

EOF

    fi

done


echo "[PASS] Chain of custody generado"
echo "$FILE"
