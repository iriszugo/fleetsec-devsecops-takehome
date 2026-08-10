#!/usr/bin/env bash

set -euo pipefail

PLAYBOOK="docs/incident-response/IR-PLAYBOOK-T0200.md"
CEO="docs/incident-response/CEO-EXECUTIVE-REPORT.md"


cat >> "$PLAYBOOK" <<'EOF'


---

# AWS CLI Exact Containment Commands Required by Audit


## IAM Privilege Revocation

Remove AdministratorAccess:

```bash
aws iam detach-user-policy \
--user-name svc-monitoring \
--policy-arn arn:aws:iam::aws:policy/AdministratorAccess
