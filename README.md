# FleetSec DevSecOps Take-Home

## Overview

FleetSec DevSecOps Take-Home is a security-focused project designed to demonstrate secure software development practices through vulnerable scenarios, automated detection, remediation, and validation.

The repository implements practical examples aligned with the OWASP Top 10, integrating static analysis, dependency scanning, automated testing, and reproducible verification scripts.

---

# Objectives

- Demonstrate secure coding practices.
- Detect vulnerabilities using Semgrep.
- Validate remediations through automated Jest tests.
- Integrate Trivy for dependency analysis.
- Prevent secret leakage using Gitleaks.
- Produce professional VAPT documentation.
- Provide reproducible verification scripts.

---

# Project Structure

```
fleetsec-devsecops-takehome
│
├── app/
│   ├── lab/
│   ├── src/
│   ├── tests/
│   └── .semgrep/
│
├── docs/
│   ├── security/
│   └── vapt/
│
├── reports/
│
├── scripts/
│
└── .github/
```

---

# Technologies

- Node.js
- Express
- Jest
- Semgrep
- Trivy
- Gitleaks
- Docker
- GitHub Actions

---

# Security Scenarios

Day 1

- SQL Injection
- Pipeline Security
- Trivy
- Gitleaks

Day 2

- JWT Algorithm Confusion
- SSRF
- Path Traversal
- Missing Rate Limiting
- IDOR

---

# Automated Validation

Day 1

```
./scripts/verify-day1.sh
```

Day 2

```
./scripts/verify-day2.sh
```

---

# Tests

Execute all security tests:

```
cd app

npm test
```

or

```
npx jest tests/security --runInBand
```

---

# Static Analysis

Example:

```
semgrep scan \
--config app/.semgrep/fleetsec-jwt-none.yml \
app/tests/semgrep/jwt-positive.js
```

---

# Dependency Analysis

```
./scripts/evaluate-trivy-sca.sh
```

---

# Documentation

VAPT reports are available under:

```
docs/vapt/
```

Each report contains:

- Executive Summary
- Technical Description
- Vulnerable Scenario
- Secure Implementation
- Detection
- Evidence
- Mitigation
- References

---

# Security Gates

The project validates:

- Semgrep
- Jest
- Trivy
- Gitleaks

before considering a scenario complete.

---

# Current Status

| Day | Status |
|------|--------|
| Day 1 | Complete |
| Day 2 | Complete |
| Day 3 | Pending |
| Day 4 | Pending |

---

# Author

FleetSec DevSecOps Take-Home

Security Engineering Demonstration Repository
