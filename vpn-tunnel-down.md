# Runbook: VPN Tunnel Down

**Service:** CloudNet Site-to-Site VPN (`CloudNet-S2S-VPN`)  
**Severity:** High  
**Last Updated:** 2026-03-26  
**Author:** Sarweshwar Patel  

---

## Symptoms

- VPN tunnel status shows **DOWN** in VPC → Site-to-Site VPN → Tunnel details
- Branch VPC instances cannot reach HQ VPC resources
- CloudWatch alarm `VPN-TunnelState` triggered
- BGP routes from Branch no longer appear in HQ route tables

---

## Impact

- Branch-to-HQ connectivity lost
- Any workloads depending on cross-VPC communication are affected
- Transit Gateway routes via VPN attachment will fail

---

## Diagnosis Steps

**Step 1 — Confirm tunnel state**
1. **VPC** → **Site-to-Site VPN Connections** → Select `CloudNet-S2S-VPN`
2. **Tunnel details** tab → Check status of both tunnels
3. Note which tunnel is DOWN (Tunnel 1 or Tunnel 2)

**Step 2 — Check Branch Router**
1. **EC2** → Select `CloudNet-Branch-Router` → Confirm status: **Running**
2. If stopped → **Instance state** → **Start**
3. Confirm Elastic IP is still associated

**Step 3 — Check IKE/IPSec on Branch Router**
1. Connect via SSM or SSH to Branch Router
2. Run: `sudo strongswan status`
3. Look for: `ESTABLISHED` (IKE) and `INSTALLED` (IPSec)
4. If not established: `sudo strongswan restart`

**Step 4 — Verify Pre-Shared Keys**
1. Check `/etc/strongswan/ipsec.secrets` — keys must match the downloaded VPN config
2. Re-download config: **VPC** → **VPN** → **Download Configuration** → Generic

**Step 5 — Check Security Group on Branch Router**
1. `CloudNet-SG-BranchRouter` must allow:
   - UDP 500 inbound from `0.0.0.0/0` (IKE)
   - UDP 4500 inbound from `0.0.0.0/0` (NAT-T)

---

## Resolution

| Scenario | Fix |
|---|---|
| Branch Router stopped | Start instance, wait for strongSwan to re-establish |
| IKE not established | `sudo strongswan restart` on Branch Router |
| Wrong pre-shared key | Re-download VPN config, update ipsec.secrets |
| SG blocking UDP 500/4500 | Add inbound rules to SG-BranchRouter |
| Both tunnels down | Check AWS Service Health Dashboard for VGW issues |

---

## Escalation

If both tunnels remain DOWN after 15 minutes and Branch Router is healthy → open AWS Support case referencing VGW ID and VPN Connection ID.

---

## Post-Incident

- Screenshot tunnel status showing UP
- Document root cause in incident log
- Verify BGP routes repropagated in HQ route tables
