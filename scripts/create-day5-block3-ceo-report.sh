#!/usr/bin/env bash

set -euo pipefail

FILE="docs/incident-response/CEO-EXECUTIVE-REPORT.md"

mkdir -p "$(dirname "$FILE")"

cat > "$FILE" <<'EOF'
# Executive Incident Report
# Incident INC-2026-001

## FleetSec S.A.S.
## Informe Ejecutivo C-Level

---

# 1. Resumen Ejecutivo

Durante el monitoreo de seguridad de la plataforma FleetSec se identificó un
incidente de ciberseguridad asociado al compromiso de una identidad IAM en AWS.

El evento involucró acceso no autorizado a recursos cloud, elevación de
privilegios y actividad compatible con extracción no autorizada de información.

El equipo de respuesta ejecutó acciones de contención orientadas a preservar
la operación, proteger evidencia digital y reducir el riesgo de impacto
adicional.

Estado actual:

- Incidente contenido.
- Credenciales comprometidas aisladas.
- Recursos críticos bajo revisión.
- Evidencias preservadas para análisis forense.


---

# 2. Impacto Identificado

## Datos potencialmente comprometidos

Volumen estimado:

**45.7 GB de información asociada a conductores**

Activo afectado:

- Bucket S3: fleetpay-prod-drivers

Riesgos identificados:

- Exposición de información personal.
- Riesgo regulatorio.
- Riesgo reputacional.
- Posible afectación a titulares de información.


---

# 3. Vector Inicial del Incidente

## Compromiso de identidad IAM

Identidad involucrada:

```text
svc-monitoring
