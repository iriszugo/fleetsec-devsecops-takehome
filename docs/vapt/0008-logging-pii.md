# V-08 — Logging de PII (CWE-359)

## 1. Executive Summary

| Campo | Valor |
|---|---|
| ID | V-08 |
| Vulnerabilidad | Logging de PII |
| CWE | CWE-359 |
| OWASP Top 10 | A09:2021 – Security Logging and Monitoring Failures |
| CVSSv3 Score oficial | 7.5 HIGH |
| Status | Mitigated |

## 2. Vulnerabilidad

El escenario vulnerable permite que datos personales sean registrados
en texto plano dentro de los logs de aplicación.

Los datos considerados incluyen:

- correo electrónico;
- documento de identidad;
- teléfono.

## 3. Riesgo

La exposición de PII en logs incrementa el riesgo de acceso
no autorizado a información personal y genera impacto de cumplimiento
frente a la Ley 1581 de 2012.

## 4. Evidencia de control

Implementación:

- `app/src/utils/piiSanitizer.js`
- `app/src/utils/securityLogger.js`

Pruebas:

- `app/tests/security/pii-sanitizer.test.js`
- `app/tests/semgrep/pii-logging-positive.js`
- `app/tests/semgrep/pii-logging-negative.js`

## 5. Remediación

Se implementó un sanitizer centralizado que redacta:

- `[REDACTED_EMAIL]`
- `[REDACTED_ID]`
- `[REDACTED_PHONE]`

El control procesa:

- strings;
- objetos;
- objetos anidados;
- arrays;
- metadata de logs.

## 6. Validación

La suite valida:

1. PII sensible → redactada.
2. Estructuras anidadas → redactadas.
3. Información legítima no sensible → preservada.

## 7. Impacto C/I/D

- Confidencialidad: Alta.
- Integridad: Baja.
- Disponibilidad: Baja.

## 8. Estado

**MITIGATED**

