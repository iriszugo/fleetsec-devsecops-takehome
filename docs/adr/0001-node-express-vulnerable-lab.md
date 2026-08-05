# ADR-0001: Node.js/Express Vulnerable Laboratory Application

## Status

Accepted

## Date

2026-08-05

## Context

FleetSec DevSecOps Take Home requires a deliberately vulnerable application to validate static analysis (SAST), dependency analysis (SCA), container security, Infrastructure as Code security, and VAPT activities.

The application is intended exclusively for laboratory and educational purposes.

## Decision

The project will use:

- Node.js LTS
- Express
- In-memory storage or SQLite with fictitious data only
- Docker as the execution environment
- GitHub Actions as the CI/CD platform

Intentional vulnerabilities will be introduced gradually according to the execution plan and documented individually.

## Constraints

- No production code.
- No real credentials.
- No personal data.
- No production infrastructure.
- No external services.

## Accepted Risks

Temporary vulnerabilities are intentionally introduced only for laboratory validation and will be remediated in subsequent phases.

## Consequences

Benefits:

- Repeatable security testing.
- Controlled vulnerability lifecycle.
- Reproducible DevSecOps pipeline.

Risks:

- The repository must never be reused in production.
- Intentional vulnerabilities must remain documented.

## References

- FleetSec Technical Assessment
- OWASP Top 10
- CWE
- CycloneDX
- GitHub Actions
