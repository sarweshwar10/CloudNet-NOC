# ADR 001: VPC CIDR Block Selection

**Date:** 2026-03-26  
**Status:** Accepted  
**Author:** Sarweshwar Patel  

---

## Context

When building CloudNet Ops, a decision was needed on how to allocate IP address space across the HQ and Branch VPCs. The CIDR blocks needed to be large enough to support multiple tiers (public, private, database) across two Availability Zones, while avoiding overlap for future VPN and Transit Gateway connectivity.

## Decision

- **HQ VPC:** `10.10.0.0/16` (65,536 IPs)
- **Branch VPC:** `10.20.0.0/16` (65,536 IPs)

Subnets were carved as `/24` blocks per tier per AZ:

| Subnet | CIDR |
|---|---|
| HQ-Public-1a | 10.10.1.0/24 |
| HQ-Public-1b | 10.10.2.0/24 |
| HQ-Private-1a | 10.10.10.0/24 |
| HQ-Private-1b | 10.10.20.0/24 |
| HQ-DB-1a | 10.10.100.0/24 |
| HQ-DB-1b | 10.10.200.0/24 |

## Rationale

- `/16` per VPC gives room to scale without re-addressing
- Non-overlapping ranges (`10.10.x.x` vs `10.20.x.x`) allow Transit Gateway and VPN connectivity without NAT
- `/24` subnets per tier per AZ are standard industry sizing — 256 IPs is sufficient for each tier at this scale
- Keeping DB subnets in the `10.10.100.x` range makes them visually distinct in routing tables and logs

## Consequences

- VPCs can be connected via TGW or VPN without IP conflicts
- Future VPCs must use non-overlapping ranges (e.g. `10.30.0.0/16`)
- The `10.0.0.0/8` supernet is reserved for all internal CloudNet infrastructure
