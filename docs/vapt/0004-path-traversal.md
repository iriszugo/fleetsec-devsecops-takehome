# Path Traversal (CWE-22)

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Vulnerability | Path Traversal |
| CWE | CWE-22 |
| OWASP Top 10 | A01:2021 – Broken Access Control |
| Severity | High |
| Status | Mitigated |

---

## 2. Description

This laboratory demonstrates a Path Traversal vulnerability where user-controlled file names are concatenated into filesystem paths. An attacker could exploit this behavior to access files outside the intended directory by using traversal sequences such as "../".

The secure implementation validates file names, normalizes paths, and verifies that the final resolved path remains inside the authorized directory before accessing the filesystem.

---

## 3. Vulnerable Scenario

Example vulnerable implementation:

```javascript
const fullPath = path.join("/tmp/files", req.params.file);
```

The requested filename is used directly without validation.

---

## 4. Secure Implementation

The secure implementation applies multiple defensive controls:

- Path normalization.
- Canonical path resolution.
- Base directory enforcement.
- Rejection of traversal sequences.
- Validation before filesystem access.

---

## 5. Detection

### Semgrep Rule

```
app/.semgrep/fleetsec-path-traversal.yml
```

Expected behavior:

- Positive fixture → 1 blocking finding.
- Negative fixture → 0 findings.

---

## 6. Automated Tests

Security test:

```
app/tests/security/path-traversal.test.js
```

Validated scenarios:

- Reject directory traversal attempts.
- Allow access to authorized files only.

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
PASS tests/security/path-traversal.test.js
```

---

## 8. Mitigation

Implemented controls:

- Canonical path validation.
- Base directory restriction.
- Normalized paths.
- Traversal sequence detection.
- Automated regression testing.
- Static analysis with Semgrep.

---

## 9. References

- https://owasp.org/www-community/attacks/Path_Traversal
- https://cwe.mitre.org/data/definitions/22.html
- https://cheatsheetseries.owasp.org/cheatsheets/File_System_Cheat_Sheet.html
