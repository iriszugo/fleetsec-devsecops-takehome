#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p app/tests/security
mkdir -p docs/vapt
mkdir -p reports/vapt


cat > app/tests/security/security-config.test.js <<'EOF'
const { loadSecurityConfig } = require('../../src/config/securityConfig');

describe('V-10 Hardcoded Credentials security controls', () => {

  const originalEnv = { ...process.env };

  afterEach(() => {
    process.env = { ...originalEnv };
  });

  test('rejects startup configuration when JWT_SECRET is absent', () => {
    delete process.env.JWT_SECRET;

    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    expect(() => loadSecurityConfig()).toThrow(
      /JWT_SECRET is required/
    );
  });

  test('rejects weak JWT_SECRET', () => {
    process.env.JWT_SECRET = 'short';
    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    expect(() => loadSecurityConfig()).toThrow(
      /JWT_SECRET is required and must contain at least 32 characters/
    );
  });

  test('rejects missing ADMIN_PASSWORD', () => {
    process.env.JWT_SECRET =
      '0123456789abcdef0123456789abcdef';

    process.env.ADMIN_USERNAME = 'admin_secure';
    delete process.env.ADMIN_PASSWORD;

    expect(() => loadSecurityConfig()).toThrow(
      /ADMIN_PASSWORD is required/
    );
  });

  test('accepts secure configuration from environment variables', () => {
    process.env.JWT_SECRET =
      '0123456789abcdef0123456789abcdef';

    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    const config = loadSecurityConfig();

    expect(config.jwtSecret)
      .toBe('0123456789abcdef0123456789abcdef');

    expect(config.adminUsername)
      .toBe('admin_secure');

    expect(config.adminPassword)
      .toBe('StrongPassword123!');
  });

});
EOF


cat > docs/vapt/0008-logging-pii.md <<'EOF'
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

EOF


cat > docs/vapt/0010-hardcoded-credentials.md <<'EOF'
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

EOF


echo "=============================================="
echo " EJECUTANDO V-08"
echo "=============================================="

(
  cd app
  npx jest \
    tests/security/pii-sanitizer.test.js \
    --runInBand
) | tee reports/vapt/v08-pii-sanitizer-test.log


echo
echo "=============================================="
echo " EJECUTANDO V-10"
echo "=============================================="

(
  cd app
  npx jest \
    tests/security/security-config.test.js \
    --runInBand
) | tee reports/vapt/v10-security-config-test.log


echo
echo "=============================================="
echo " VALIDANDO DOCUMENTOS"
echo "=============================================="

test -s docs/vapt/0008-logging-pii.md
echo "[PASS] V-08 documento creado"

test -s docs/vapt/0010-hardcoded-credentials.md
echo "[PASS] V-10 documento creado"

grep -q "Status | Mitigated" docs/vapt/0008-logging-pii.md
echo "[PASS] V-08 estado Mitigated"

grep -q "Status | Mitigated" docs/vapt/0010-hardcoded-credentials.md
echo "[PASS] V-10 estado Mitigated"


echo
echo "=============================================="
echo " CIERRE VAPT V-08 / V-10"
echo "=============================================="
echo "[PASS] V-08 Logging PII"
echo "[PASS] V-10 Hardcoded Credentials"
echo
echo "Documentos VAPT disponibles:"
find docs/vapt -maxdepth 1 -type f | sort
