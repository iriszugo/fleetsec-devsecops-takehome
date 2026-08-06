# {{TITLE}}

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | |
| CWE | |
| OWASP Top 10 | |
| Severity | |
| Status | Mitigated |

---

## 2. Description

Describe the vulnerability, the affected component, and the security impact.

---

## 3. Vulnerable Scenario

Explain how the vulnerable implementation works.

---

## 4. Secure Implementation

Explain the mitigation that was implemented.

---

## 5. Detection

### Semgrep Rule

Rule:

```
.semgrep/<rule>.yml
```

Expected behaviour:

- Positive fixture → Finding detected
- Negative fixture → No findings

---

## 6. Automated Tests

Security tests:

```
tests/security/<test>.test.js
```

Expected result:

```
PASS
```

---

## 7. Evidence

### Positive fixture

```
Findings: 1 (1 blocking)
```

### Negative fixture

```
Findings: 0
```

### Jest

```
PASS
```

---

## 8. Mitigation

Describe the implemented control and why it prevents exploitation.

---

## 9. References

- OWASP
- CWE
- Official vendor documentation
