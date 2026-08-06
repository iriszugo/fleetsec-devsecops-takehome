# Missing Rate Limiting (CWE-307)

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | Missing Rate Limiting |
| CWE | CWE-307 |
| OWASP Top 10 | A07:2021 – Identification and Authentication Failures |
| Severity | Medium |
| Status | Mitigated |

---

## 2. Description

This laboratory demonstrates an authentication endpoint without request throttling. An attacker could perform brute-force attacks by submitting an unlimited number of authentication attempts.

The secure implementation introduces rate limiting using Express Rate Limit to restrict repeated requests from the same client.

---

## 3. Vulnerable Scenario

Example vulnerable implementation:

```javascript
app.post("/login", (req, res) => {
    return res.status(200).json({
        authenticated: true
    });
});
```

No restrictions exist on repeated authentication attempts.

---

## 4. Secure Implementation

The mitigation uses `express-rate-limit` to protect authentication endpoints.

Security controls:

- Maximum failed requests.
- Fixed time window.
- Automatic HTTP 429 responses.
- Consistent middleware enforcement.

---

## 5. Detection

### Semgrep Rule

```
app/.semgrep/fleetsec-missing-rate-limit.yml
```

Expected behavior:

- Positive fixture → 1 blocking finding.
- Negative fixture → 0 findings.

---

## 6. Automated Tests

Security test:

```
app/tests/security/rate-limit.test.js
```

Validated scenarios:

- Reject repeated authentication attempts.
- Allow valid authentication before the limit.

Expected result:

```
PASS
```

---

## 7. Evidence

### Positive Fixture

```
Findings: 1 (Blocking)
```

### Negative Fixture

```
Findings: 0
```

### Jest

```
PASS tests/security/rate-limit.test.js
```

---

## 8. Mitigation

Implemented controls:

- Express Rate Limit middleware.
- HTTP 429 responses.
- Login endpoint protection.
- Automated regression tests.
- Static analysis using Semgrep.

---

## 9. References

- https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/
- https://cwe.mitre.org/data/definitions/307.html
- https://github.com/express-rate-limit/express-rate-limit
