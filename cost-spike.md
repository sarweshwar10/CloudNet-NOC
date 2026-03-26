# Runbook: Unexpected Cost Spike

**Service:** AWS Billing / Cost Explorer  
**Severity:** Medium  
**Last Updated:** 2026-03-26  
**Author:** Sarweshwar Patel  

---

## Symptoms

- AWS Budgets alarm triggered (budget threshold exceeded)
- Email alert from `CloudNet-Monthly-Budget`
- Cost Explorer showing unexpected daily spend spike
- Unrecognized services appearing in billing

---

## CloudNet Known Cost Drivers

| Service | Approx Cost | Notes |
|---|---|---|
| Network Firewall | ~$0.40/hr = ~$288/mo | Delete after testing! |
| NAT Gateway | ~$0.045/hr + data = ~$32/mo | Delete after testing! |
| Transit Gateway | ~$0.05/hr per attachment = ~$72/mo | Delete after testing! |
| RDS (Multi-AZ) | ~$25-50/mo | Stop when not in use |
| EC2 t2.micro | Free tier (750 hrs/mo) | Watch instance count |
| Site-to-Site VPN | ~$36/mo | Delete after testing! |

---

## Diagnosis Steps

**Step 1 — Check AWS Budgets**
1. **Billing** → **Budgets** → Select `CloudNet-Monthly-Budget`
2. Check actual vs forecasted spend
3. Note which day the spike started

**Step 2 — Cost Explorer Drill-Down**
1. **Billing** → **Cost Explorer** → **Launch Cost Explorer**
2. Set date range to last 7 days
3. **Group by: Service** → Identify top cost driver
4. **Group by: Usage Type** → Drill into the specific service

**Step 3 — Check for Forgotten Resources**
Run through this checklist:

| Resource | Where to Check |
|---|---|
| Network Firewall running? | VPC → Network Firewall |
| NAT Gateway still exists? | VPC → NAT Gateways |
| Transit Gateway attached? | VPC → Transit Gateways |
| RDS running? | RDS → Databases |
| Unexpected EC2 instances? | EC2 → Instances (all regions!) |
| Unattached Elastic IPs? | VPC → Elastic IPs |
| Large S3 data transfer? | S3 → Metrics |

**Step 4 — Check All Regions**
⚠️ Resources in OTHER regions don't show in us-east-1 console view.
1. Top right → Switch region → Check EC2, RDS, NAT GW in each region
2. **Billing → Cost Explorer → Group by: Region** to identify which region

---

## Resolution

| Scenario | Fix |
|---|---|
| Network Firewall left running | VPC → Network Firewall → Delete |
| NAT Gateway left running | VPC → NAT Gateways → Delete |
| Transit Gateway attached | Delete attachments first, then TGW |
| Unattached Elastic IPs | VPC → Elastic IPs → Release all unused |
| Unexpected instances | EC2 → Terminate unknown instances |
| RDS running idle | RDS → Stop temporarily (stops for 7 days max) |

**Emergency: Immediately reduce spend**
Follow the Cleanup section in the CloudNet Build Guide — delete in exact order to avoid dependency errors.

---

## Post-Incident

- Confirm next day Cost Explorer shows spend returning to baseline
- Add more granular Budget alerts (e.g. 50%, 75%, 90% thresholds)
- Tag all resources with `Project=CloudNet` for cost allocation tracking
- Next day: **Billing → Cost Explorer → Verify $0** ✅
