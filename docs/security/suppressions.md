# Security Suppressions Register

This document governs every suppression applied within the FleetSec DevSecOps Laboratory.

No suppression may be introduced into scanners or pipelines without being documented here.

| ID | Tool | Finding | Justification | Expiration | Owner | Evidence | Status |
|----|------|---------|---------------|------------|-------|----------|--------|
| None | N/A | N/A | No active suppressions | N/A | Iris Patricia Zúñiga Gómez | N/A | Active |

---

## Day 2 Approved Suppression

| ID | Tool | Scope | Justification | Expiration | Owner | Status |
|----|------|-------|---------------|------------|-------|--------|
| **SUP-D2-01** | Semgrep | `app/lab/vulnerable/` | Laboratory code intentionally contains exploitable vulnerabilities used exclusively for security validation, Semgrep rules, regression testing and VAPT evidence. These findings must never be considered production code. | 2026-08-31 | Iris Patricia Zúñiga Gómez | Active |
