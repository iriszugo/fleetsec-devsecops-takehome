# SQL Injection (CWE-89)

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | SQL Injection |
| CWE | CWE-89 |
| OWASP Top 10 | A03:2021 – Injection |
| Severity | High |
| Status | Mitigated |

---

## 2. Description

The laboratory intentionally implements a vulnerable SQL query that concatenates user-controlled input directly into the SQL statement. This allows an attacker to manipulate the query and retrieve or alter unauthorized data.

A secure implementation uses parameterized queries and prepared statements, eliminating SQL injection attacks.

---

## 3. Vulnerable Scenario

Example vulnerable code:

```javascript
const query =
  "SELECT * FROM users WHERE username = '" +
  username +
  "'";
```

User input is concatenated directly into the SQL query.

---

## 4. Secure Implementation

The secure implementation replaces string concatenation with parameterized queries.

Example:

```javascript
db.all(
  "SELECT id, username FROM users WHERE username = ?",
  [username]
);
```

---

## 5. Detection

### Semgrep Rule

```
.semgrep/fleetsec-sqli.yml
```

Expected behaviour

- Positive fixture → Finding detected
- Negative fixture → No findings

---

## 6. Automated Tests

Security tests

```
tests/security/health.test.js
```

Validation script

```
verify-day1.sh
```

Expected result

```
PASS
```

---

## 7. Evidence

### Positive fixture

```
Findings: 1 (Blocking)
```

### Negative fixture

```
Findings: 0
```

### Pipeline

```
PASS
```

---

## 8. Mitigation

- Parameterized SQL queries.
- No string concatenation.
- Secure coding practices.
- Static analysis using Semgrep.

---

## 9. References

- https://owasp.org/www-community/attacks/SQL_Injection
- https://cwe.mitre.org/data/definitions/89.html
- https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
