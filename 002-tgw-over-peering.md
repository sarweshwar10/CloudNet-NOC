# ADR 002: Transit Gateway Over VPC Peering

**Date:** 2026-03-26  
**Status:** Accepted  
**Author:** Sarweshwar Patel  

---

## Context

CloudNet Ops requires connectivity between the HQ VPC and Branch VPC. Two options were evaluated: VPC Peering and Transit Gateway (TGW). A Site-to-Site VPN was also set up separately to simulate on-prem connectivity.

## Decision

Use **AWS Transit Gateway** (`CloudNet-TGW`, ASN `64512`) as the primary hub for inter-VPC routing. VPC Peering was created for documentation purposes only — it does not carry production traffic.

## Rationale

| Factor | VPC Peering | Transit Gateway |
|---|---|---|
| Scalability | N*(N-1)/2 connections | Single hub, add spokes |
| Transitive routing | ❌ Not supported | ✅ Supported |
| BGP support | ❌ No | ✅ Yes |
| Centralized route control | ❌ No | ✅ TGW Route Tables |
| Cost | Lower (no hourly fee) | ~$0.05/hr per attachment |

VPC Peering does not support transitive routing — if a third VPC is added later, peering requires a full mesh. TGW scales linearly and supports centralized routing policy.

## Consequences

- All inter-VPC traffic routes through `CloudNet-TGW`
- Route tables in HQ and Branch VPCs point `10.x.x.x` traffic to TGW
- Additional VPCs or on-prem connections can be added as TGW attachments without restructuring
- Cost: ~$0.05/hr per attachment — acceptable for the connectivity and scalability gained
