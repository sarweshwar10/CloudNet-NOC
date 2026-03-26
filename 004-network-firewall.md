# ADR 004: AWS Network Firewall for Perimeter Inspection

**Date:** 2026-03-26  
**Status:** Accepted  
**Author:** Sarweshwar Patel  

---

## Context

CloudNet Ops requires deep packet inspection and Layer 7 traffic filtering at the VPC perimeter. Security Groups and NACLs operate at Layer 3/4 only. A decision was needed on whether to deploy AWS Network Firewall or rely solely on existing controls.

## Decision

Deploy **AWS Network Firewall** in the HQ VPC public subnets for stateful and stateless inspection of all ingress/egress traffic.

## Rationale

| Control | Layer | Stateful | L7 Inspection | Suricata Rules |
|---|---|---|---|---|
| Security Groups | 3/4 | ✅ | ❌ | ❌ |
| NACLs | 3/4 | ❌ | ❌ | ❌ |
| Network Firewall | 3-7 | ✅ | ✅ | ✅ |

Security Groups and NACLs cannot inspect HTTP headers, DNS queries, or detect protocol anomalies. Network Firewall supports Suricata-compatible rules, enabling signature-based threat detection aligned with the IDS/IPS skills from the CloudNet security background.

## Implementation

- Deployed in both public subnets (us-east-1a, us-east-1b) for HA
- Stateless rules: drop invalid TCP flags, allow established flows
- Stateful rules: block known malicious domains, allow only HTTP/HTTPS/DNS outbound
- Flow logs sent to CloudWatch Logs for analysis

## Consequences

- All traffic entering/leaving the VPC passes through firewall inspection
- Cost: ~$0.40/hr — highest cost component, delete after testing
- Rule updates are centralized — no per-instance configuration needed
- Provides compliance evidence for perimeter inspection requirements
