#!/usr/bin/env bash

set -euo pipefail

mkdir -p docs/incident-response


cat > docs/incident-response/MITRE-ATTACK-MAP.md <<'EOF'
# MITRE ATT&CK v14 Mapping
# Incident INC-2026-001

## Contexto

Incidente de compromiso AWS con escalamiento IAM, exfiltración de información,
ejecución de infraestructura no autorizada y posible intento de evasión de controles.

---

| Técnica MITRE | Caso identificado | Evidencia | Mitigación |
|---|---|---|---|
| T1078 - Valid Accounts | Uso de credenciales válidas del usuario svc-monitoring comprometido | Actividad CloudTrail asociada al usuario IAM | MFA, IAM Least Privilege, rotación de credenciales |
| T1098 - Account Manipulation | Escalamiento mediante asignación de AdministratorAccess | Cambio no autorizado de privilegios IAM | Alertas IAM, revisión periódica permisos, SCP Deny |
| T1567 - Exfiltration Over Web Service | Extracción masiva de datos desde bucket S3 fleetpay-prod-drivers | Eventos s3:GetObject y transferencia anómala | S3 Access Control, CloudTrail Data Events, GuardDuty |
| T1048 - Exfiltration Over Alternative Protocol | Exfiltración mediante canal alternativo DNS | Tráfico DNS anómalo desde instancia EC2 | VPC Flow Logs, DNS monitoring, Network Firewall |
| T1562.001 - Impair Defenses | Intento de desactivar CloudTrail mediante DeleteTrail | Evento CloudTrail DeleteTrail | SCP Deny, CloudTrail protegido, alertas críticas |
| T1071.004 - Application Layer Protocol: DNS | Uso de DNS como canal de comunicación C2 | Consultas DNS sospechosas | DNS logging, GuardDuty DNS findings |

---

# Controles asociados

## Preventivos

- IAM Least Privilege
- MFA obligatorio
- SCP Organizations
- S3 Block Public Access
- KMS Encryption
- WAF

## Detectivos

- CloudTrail
- GuardDuty
- Security Hub
- VPC Flow Logs
- CloudWatch Logs

## Correctivos

- Revocación credenciales
- Aislamiento recursos
- Preservación forense
- Recuperación controlada

EOF



cat > docs/incident-response/RCA-INCIDENT-2026.md <<'EOF'
# Root Cause Analysis
# Incident INC-2026-001

## 1. Resumen ejecutivo

Se detectó un incidente de seguridad en infraestructura AWS asociado al compromiso
del usuario IAM svc-monitoring.

El incidente involucró:

- Escalamiento de privilegios.
- Acceso no autorizado a almacenamiento S3.
- Posible exfiltración de datos.
- Uso de infraestructura para actividades no autorizadas.

---

# 2. Línea temporal

| Tiempo | Evento |
|---|---|
| T+00:00 | Detección de actividad sospechosa desde IP 185.220.101.22 |
| T+00:30 | Identificación usuario IAM comprometido |
| T+01:00 | Evidencia de privilegios elevados |
| T+01:30 | Detección acceso masivo S3 |
| T+02:00 | Inicio proceso de contención |

---

# 3. Vector inicial probable

## Hipótesis principal

Compromiso de credenciales IAM pertenecientes al usuario svc-monitoring.

Factores contribuyentes:

- Privilegios excesivos.
- Falta de segmentación de permisos.
- Ausencia de controles preventivos suficientes.
- Falta de alertamiento temprano.

---

# 4. Causa raíz

## Técnica

Gestión inadecuada de identidad y privilegios:

- Uso de permisos administrativos.
- Falta de mínimo privilegio.
- Exposición potencial de credenciales.
- Falta de controles adaptativos.

## Organizacional

- Falta de revisión periódica IAM.
- Falta de monitoreo continuo.
- Falta de ejercicios formales de respuesta.

---

# 5. Impacto

Activos afectados:

- Usuario IAM svc-monitoring.
- Bucket S3 fleetpay-prod-drivers.
- Instancia EC2 comprometida.
- Cluster ECS fleetsec-prod-cluster.

Datos potencialmente afectados:

- Información operativa.
- Datos asociados a conductores.

---

# 6. Contención aplicada

Acciones:

- Revocación de credenciales.
- Eliminación privilegios AdministratorAccess.
- Aplicación Deny explícito.
- Aislamiento EC2.
- Detención ECS.
- Protección evidencias.

---

# 7. Plan de remediación

## P1 - 24 horas

- Contención completa.
- Rotación credenciales.
- Bloqueo accesos sospechosos.

## P2 - 7 días

- Auditoría IAM.
- Implementación MFA.
- Revisión arquitectura AWS.

## P3 - 30 días

- Zero Trust.
- Automatización detección.
- Simulacros IR.

---

# 8. Lecciones aprendidas

- Reducir privilegios permanentes.
- Mejorar detección temprana.
- Fortalecer monitoreo.
- Mantener procedimientos IR actualizados.

EOF


echo "[PASS] MITRE ATT&CK MAP creado"
echo "[PASS] RCA INCIDENT creado"
