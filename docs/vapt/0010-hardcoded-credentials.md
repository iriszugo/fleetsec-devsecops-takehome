# V-10 — Hardcoded Credentials (CWE-798)

## 1. Executive Summary

| Campo | Valor |
|---|---|
| ID | V-10 |


| Vulnerabilidad | Hardcoded Credentials |
| CWE | CWE-798 |
| OWASP Top 10 | A07:2021 – Identification and Authentication Failures |
| CVSSv3 Score oficial | 9.0 CRITICAL |
| Status | Mitigated |

## 2. Vulnerabilidad

El riesgo consiste en almacenar secretos o credenciales directamente
dentro del código fuente o archivos versionados.

## 3. Remediación

Los secretos fueron migrados a variables de entorno:

- `JWT_SECRET`
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`

Implementación:

- `app/src/config/securityConfig.js`
- `app/src/routes/auth.js`
- `app/src/middleware/auth.js`
- `app/src/routes/login.js`
- `.env.example`

El archivo `.env.example` contiene únicamente valores de referencia,
nunca secretos reales.

## 4. Fail-Closed

`loadSecurityConfig()` rechaza la configuración cuando:

- JWT_SECRET no existe;
- JWT_SECRET tiene menos de 32 caracteres;
- ADMIN_USERNAME no existe;
- ADMIN_PASSWORD no existe;
- ADMIN_PASSWORD no cumple longitud mínima.

## 5. Evidencia de prueba

Prueba:

`app/tests/security/security-config.test.js`

La suite demuestra:

1. secreto ausente → rechazo;
2. secreto débil → rechazo;
3. password ausente → rechazo;
4. configuración legítima mediante variables → OK.

## 6. Impacto C/I/D

- Confidencialidad: Alta.
- Integridad: Alta.
- Disponibilidad: Media.

## 7. Estado

**MITIGATED**


Debe quedar al final exactamente así:

```markdown
### Test result

```text
Test Suites: 1 passed, 1 total
Tests:       4 passed, 4 total
## 9. PoC Evidence

PoC: insecure configuration with missing or weak credentials.

The following malicious or insecure conditions were tested:

- JWT_SECRET absent -> rejected.
- JWT_SECRET weak -> rejected.
- ADMIN_PASSWORD absent -> rejected.

Proof:

`app/tests/security/security-config.test.js`

The application fails closed when a mandatory secret is absent or weak.

Legitimate flow:

A valid configuration supplied through environment variables is accepted successfully.

Status: **MITIGATED AND VERIFIED**
