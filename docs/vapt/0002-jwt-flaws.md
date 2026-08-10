
## 1. Executive Summary

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | JWT Algorithm Confusion ("alg":"none") |
| Primary CWE | CWE-345 – Insufficient Verification of Data Authenticity |
| Related CWE | CWE-347 – Improper Verification of Cryptographic Signature |
| OWASP Top 10 | A07:2021 – Identification and Authentication Failures |
| Severity | High |
| Status | Mitigated |
---

## 2. Description

This laboratory demonstrates an insecure JWT implementation where a token may be accepted without proper signature verification.

A vulnerable implementation may trust attacker-controlled claims when the token is decoded or verified without explicitly restricting the accepted algorithms.

The secure implementation enforces a strong shared secret, explicitly restricts accepted algorithms to **HS256**, and validates every received token before any claim is processed.

---

## Weakness Classification (CWE)

### Primary CWE

- **CWE-345 – Insufficient Verification of Data Authenticity**

The vulnerable implementation accepts a JWT without sufficiently verifying its authenticity before trusting its claims.

### Related CWE

- **CWE-347 – Improper Verification of Cryptographic Signature**

The vulnerable implementation also fails to properly enforce cryptographic signature validation by allowing insecure JWT algorithm configurations (for example, accepting or failing to reject the `alg: none` algorithm).


---

## 3. Vulnerable Scenario

The vulnerable implementation accepts JWT tokens without enforcing algorithm restrictions.

Example:

```javascript
jwt.decode(token);
```

or

```javascript
jwt.verify(token, secret);
```

without specifying the allowed algorithms.

An attacker can craft a forged token using:

```
alg = none
```

and impersonate another user.

---

## 4. Secure Implementation

The application validates every JWT using:

```javascript
jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ["HS256"]
});
```

Security controls implemented:

- Minimum 32-character secret.
- HS256 enforced.
- Tokens without valid signatures are rejected.
- Centralized authentication middleware.

---

## 5. Detection

### Semgrep Rule

```
app/.semgrep/fleetsec-jwt-none.yml
```

Expected behavior:

- Positive fixture → 1 blocking finding.
- Negative fixture → 0 findings.

---

## 6. Automated Tests

Security test:

```
app/tests/security/jwt.test.js
```

Validated scenarios:

- Reject forged JWT using alg:none.
- Accept valid HS256 token.

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
PASS tests/security/jwt.test.js
```

---

## 8. Mitigation

Implemented controls:

- Enforce HS256.
- Reject "none" algorithm.
- Require strong JWT secret.
- Validate signatures before processing claims.
- Security regression tests.
- Static analysis using Semgrep.

---

## 9. References

- https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/
https://cwe.mitre.org/data/definitions/345.html
https://cwe.mitre.org/data/definitions/347.html

- https://datatracker.ietf.org/doc/html/rfc7519
- https://github.com/auth0/node-jsonwebtoken
