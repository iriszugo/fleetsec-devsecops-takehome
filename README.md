# FleetSec DevSecOps Take Home

## Overview

FleetSec is a secure-by-design laboratory developed as part of a DevSecOps technical assessment.

The objective of this repository is to demonstrate the implementation of modern application security controls across the software development lifecycle (SDLC), integrating Security by Design principles into CI/CD pipelines.

The project progressively introduces intentionally vulnerable laboratory scenarios together with their secure implementations, automated security testing, custom static analysis rules, documentation and verification scripts.

---

## Objectives

- Build a vulnerable Express application for security testing.
- Demonstrate secure implementations for each vulnerability.
- Integrate DevSecOps controls into CI/CD.
- Produce reproducible verification scripts.
- Generate technical evidence suitable for security assessments.

---

## Technology Stack

- Node.js
- Express
- Docker
- GitHub Actions
- Semgrep
- Trivy
- Gitleaks
- CycloneDX SBOM
- Jest
- Helmet

---

## Project Structure

```text
app/
docs/
reports/
scripts/
.github/
```

---

## Progress

| Day | Status |
|------|--------|
| Day 0 | ✅ Completed |
| Day 1 | ✅ Completed |
| Day 2 | ✅ Completed |
| Day 3 | ✅ Completed |

---

*Detailed technical documentation is available under the `/docs` directory.*

---

# Implemented Security Controls

| Vulnerability | CWE | Status |
|---------------|-----|--------|
| SQL Injection | CWE-89 | ✅ |
| JWT `alg:none` | CWE-345 | ✅ |
| Server-Side Request Forgery (SSRF) | CWE-918 | ✅ |
| Path Traversal | CWE-22 | ✅ |
| Missing Rate Limiting | CWE-307 | ✅ |
| Insecure Direct Object Reference (IDOR) | CWE-639 | ✅ |
| OS Command Injection | CWE-78 | ✅ |

---

# Secure Controls Implemented

- Parameterized SQL queries
- JWT signature validation
- URL allowlisting
- Secure file path validation
- Rate limiting middleware
- Authorization checks (IDOR mitigation)
- Safe process execution using `execFile()`
- HTTP hardening with Helmet
- Request body size limitation
- Removal of `X-Powered-By`
- Custom Semgrep rules
- Jest security tests
- Technical VAPT documentation
- Verification scripts for Day 1, Day 2 and Day 3



---

# Getting Started

## Clone repository

```bash
git clone <repository-url>
cd fleetsec-devsecops-takehome
```

## Install dependencies

```bash
cd app
npm install
```

## Start application

```bash
npm start
```

Application:

```
http://localhost:3000
```

Health endpoint:

```
http://localhost:3000/health
```

---

# Running Security Tests

## Execute Jest

```bash
cd app
npm test
```

## Execute Day 1 verification

```bash
./scripts/verify-day1.sh
```

## Execute Day 2 verification

```bash
./scripts/verify-day2.sh
```

## Execute Day 3 verification

```bash
./scripts/verify-day3.sh
```


---

# DevSecOps Pipeline

The project integrates automated security controls into the CI/CD workflow.

## Security Gates

- Source checkout
- Dependency installation
- Jest unit tests
- Custom Semgrep SAST rules
- Gitleaks secret scanning
- CycloneDX SBOM generation
- Trivy filesystem scanning
- Verification scripts
- Security reports generation

---

# Verification Scripts

| Script | Purpose |
|---------|----------|
| verify-day1.sh | Validate Day 1 deliverables |
| verify-day2.sh | Validate Day 2 deliverables |
| verify-day3.sh | Validate Day 3 deliverables |

---

# Security Reports

Generated reports include:

- Semgrep
- Trivy
- SBOM
- Gitleaks
- Jest
- Docker validation
- Health endpoint validation

Reports are stored under:

```text
reports/
```

---

# Current Status

- ✅ Day 0 completed
- ✅ Day 1 completed
- ✅ Day 2 completed
- ✅ Day 3 completed

Repository ready to continue with Day 4 implementation.

## Arquitectura Final

La arquitectura final FleetSec integra Application Security, DevSecOps CI/CD, AWS Infrastructure as Code y Detection/Incident Response.

### Capas implementadas

1. **Application Security:** JWT, Helmet, rate limiting, sanitización PII y controles contra SQL Injection, SSRF, IDOR, Path Traversal y Command Injection.
2. **DevSecOps:** Gitleaks, Semgrep, Trivy, CycloneDX SBOM, Checkov y OWASP ZAP autenticado mediante JWT/OpenAPI con cobertura >=80% y Quality Gates.
3. **AWS IaC:** IAM, KMS, S3, VPC, RDS, Secrets Manager, WAF, CloudTrail, GuardDuty, Security Hub y AWS Config.
4. **Detection & IR:** Threat Intelligence, Sigma, MITRE ATT&CK, playbook de contención, RCA y Chain of Custody.

### Flujo de seguridad

Developer -> Pre-commit/Gitleaks -> GitHub Actions -> SAST/SCA/SBOM/IaC -> Security Gate -> Application -> Authenticated ZAP DAST -> AWS Security Baseline -> Detection -> Incident Response

### Alineación

| Marco | Controles |
|---|---|
| CIS AWS Foundations | IAM, logging, monitoreo y configuración segura |
| ISO/IEC 27001:2022 | Accesos, vulnerabilidades, logging e incidentes |
| Ley 1581 de 2012 | Protección de PII y gestión de incidentes de datos |

## Sustentación técnica

Guion: `docs/VIDEO-SCRIPT.md`

La grabación final debe cubrir Arquitectura, Pipeline, dos vulnerabilidades y Breach Response en máximo 10 minutos.

## Informe VAPT

Entregable final: `reports/vapt/FleetSec_VAPT_Report.pdf`
