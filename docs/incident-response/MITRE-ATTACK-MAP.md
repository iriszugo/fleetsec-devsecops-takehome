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

