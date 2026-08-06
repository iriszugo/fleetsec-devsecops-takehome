# Command Injection (CWE-78)

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | OS Command Injection |
| Primary CWE | CWE-78 – Improper Neutralization of Special Elements used in an OS Command |
| OWASP Top 10 | A03:2021 – Injection |
| Severity | Critical |
| Status | Mitigated |

---

## 2. Description

This laboratory demonstrates an OS Command Injection vulnerability where untrusted user input is concatenated into an operating system command.

The vulnerable implementation executes shell commands directly through `child_process.exec()`, allowing an attacker to inject additional operating system instructions.

The secure implementation eliminates shell execution by using `execFile()` with `shell: false`, a strict allowlist of permitted operations, input validation and execution limits.

---

## 3. Vulnerable Scenario

Example of insecure implementation:

```javascript
const command = `ping -c 1 ${host}`;
exec(command);
```

An attacker could attempt inputs such as:

```
127.0.0.1; whoami
```

or

```
127.0.0.1 && cat /etc/passwd
```

---

## 4. Secure Implementation

The secure endpoint applies the following controls:

```javascript
execFile("/bin/ping", ["-c", "1", host], {
    shell: false,
    timeout: 3000
});
```

Security controls implemented:

- No shell interpreter.
- Allowlisted executable.
- Input validation.
- Host validation.
- Execution timeout.
- Output buffer limit.
- Generic error handling.

---

## 5. Detection

### Semgrep Rule

```
app/.semgrep/fleetsec-command-injection.yml
```

Expected behavior:

- Positive fixture → 1 blocking finding.
- Negative fixture → 0 findings.

---

## 6. Automated Tests

Security test:

```
app/tests/security/command-injection.test.js
```

Validated scenarios:

- Reject shell metacharacters.
- Accept valid host.

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
PASS tests/security/command-injection.test.js
```

---

## 8. Mitigation

Implemented controls:

- execFile instead of exec.
- shell disabled.
- Allowlisted executable.
- Input validation.
- Execution timeout.
- Security regression tests.
- Static analysis using Semgrep.

---

## 9. References

- https://owasp.org/Top10/A03_2021-Injection/
- https://cwe.mitre.org/data/definitions/78.html
- https://nodejs.org/api/child_process.html
