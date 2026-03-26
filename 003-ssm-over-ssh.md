# ADR 003: SSM Session Manager Over SSH

**Date:** 2026-03-26  
**Status:** Accepted  
**Author:** Sarweshwar Patel  

---

## Context

EC2 instances in the private subnets needed a secure access method for administration and troubleshooting. Two options were evaluated: traditional SSH via a Bastion Host, and AWS Systems Manager (SSM) Session Manager.

## Decision

Use **AWS SSM Session Manager** exclusively for EC2 access. SSH (port 22) is not open on `CloudNet-SG-AppServer`. No Bastion Host is required for private instance access.

## Rationale

| Factor | SSH + Bastion | SSM Session Manager |
|---|---|---|
| Open ports required | Port 22 on Bastion + SG | None |
| Key management | .pem files per user | IAM roles |
| Audit trail | None by default | CloudTrail + CloudWatch Logs |
| MFA support | ❌ Complex to implement | ✅ Via IAM policy |
| Cost | EC2 Bastion (~$8/mo) | Free (SSM is free) |
| Zero Trust alignment | ❌ No | ✅ Yes |

SSM aligns with Zero Trust principles — no standing network access, all sessions authenticated via IAM, all activity logged automatically.

## Implementation

- EC2 IAM Role: `EC2-S3-SSM-Role` includes `AmazonSSMManagedInstanceCore`
- VPC Endpoints created for `ssm`, `ssmmessages`, `ec2messages` — no internet required
- SSH rule was never added to `CloudNet-SG-AppServer`

## Consequences

- All instance access goes through IAM — revoking access is instant (remove IAM permission)
- Every session is logged in CloudTrail — full audit trail for compliance
- No .pem key files to manage or rotate
- Instances in fully private subnets (no public IP) are still accessible
