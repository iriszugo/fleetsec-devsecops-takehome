# IR-PLAYBOOK-T0200
# AWS Active Breach Containment Playbook

## 1. Objetivo

Procedimiento de contención operativa para incidente activo de seguridad AWS
(T+02:00), incluyendo aislamiento IAM, S3, EC2, ECS y validación CloudTrail.

Escenario:

- Usuario comprometido: svc-monitoring
- IP origen sospechosa: 185.220.101.22
- Riesgo identificado:
  - Escalamiento IAM
  - Exfiltración S3
  - Persistencia
  - Ejecución de infraestructura no autorizada


---

# 2. IAM Containment

## 2.1 Identificación usuario comprometido

Validación:

```bash
aws iam get-user \
--user-name svc-monitoring
