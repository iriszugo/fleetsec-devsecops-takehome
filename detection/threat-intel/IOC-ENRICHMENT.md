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
