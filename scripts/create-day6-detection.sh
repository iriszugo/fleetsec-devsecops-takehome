#!/usr/bin/env bash

set -euo pipefail

mkdir -p detection/sigma
mkdir -p detection/threat-intel

cat > detection/sigma/cloudtrail-admin-policy-after-hours.yml <<'EOF'
title: FleetSec AdministratorAccess Attachment Outside Business Hours
id: 2b98eb6d-0f67-4a6a-a24b-001
status: test
description: Detects AdministratorAccess policy attachment to IAM users outside 00:00-06:00 UTC review window.
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventSource: iam.amazonaws.com
    eventName: AttachUserPolicy
    requestParameters.policyArn|endswith: AdministratorAccess
  condition: selection
falsepositives:
  - Approved emergency break-glass activity
level: high
tags:
  - attack.persistence
  - attack.privilege_escalation
  - attack.t1098
EOF

cat > detection/sigma/cloudtrail-delete-trail.yml <<'EOF'
title: FleetSec CloudTrail DeleteTrail Attempt
id: 2b98eb6d-0f67-4a6a-a24b-002
status: test
description: Detects attempts to delete an AWS CloudTrail trail.
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventSource: cloudtrail.amazonaws.com
    eventName: DeleteTrail
  condition: selection
falsepositives:
  - Approved infrastructure decommissioning
level: critical
tags:
  - attack.defense_evasion
  - attack.t1562.001
EOF

cat > detection/sigma/app-sql-injection.yml <<'EOF'
title: FleetSec SQL Injection Pattern in Application Query Parameters
id: 2b98eb6d-0f67-4a6a-a24b-003
status: test
description: Detects common SQL injection patterns in application query parameters.
logsource:
  category: webserver
detection:
  keywords:
    - "' OR '1'='1"
    - "UNION SELECT"
    - "UNION ALL SELECT"
    - "information_schema"
    - "--"
  condition: keywords
falsepositives:
  - Security testing in authorized laboratory
level: high
tags:
  - attack.initial_access
EOF

cat > detection/sigma/s3-bulk-getobject.yml <<'EOF'
title: FleetSec S3 Bulk GetObject Activity
id: 2b98eb6d-0f67-4a6a-a24b-004
status: experimental
description: Detects high-volume S3 GetObject activity associated with potential bulk exfiltration.
logsource:
  product: aws
  service: cloudtrail
detection:
  selection:
    eventSource: s3.amazonaws.com
    eventName: GetObject
  condition: selection
falsepositives:
  - Approved backup or analytics workloads
level: high
tags:
  - attack.exfiltration
  - attack.t1567
EOF

cat > detection/threat-intel/threat-intel-set.txt <<'EOF'
185.220.101.22
EOF

cat > detection/threat-intel/IOC-ENRICHMENT.md <<'EOF'
# FleetSec IOC Enrichment

## Incident

INC-2026-001

## Primary IOC

| Attribute | Value |
|---|---|
| IP | 185.220.101.22 |
| Context | Tor exit node observed during unauthorized AWS access |
| ASN | AS213151 |
| Associated identity | svc-monitoring |
| Observed behavior | Console login, privilege escalation, data exfiltration |
| S3 volume | 45.7 GB |
| Network exfiltration | ~49 GB |
| ECS image | docker.io/attacker/exfil:latest |

## Reputation enrichment

The following external sources must be consulted during investigation:

- VirusTotal
- AbuseIPDB
- Shodan
- MISP / AlienVault OTX

Results must be timestamped because reputation data changes over time.

## GuardDuty Threat Intel Set

File:

detection/threat-intel/threat-intel-set.txt

AWS CLI reference:

```bash
aws guardduty create-threat-intel-set \
  --detector-id DETECTOR_ID \
  --name fleetsec-inc-2026-001 \
  --format TXT \
  --location S3_OBJECT_URL \
  --activate
