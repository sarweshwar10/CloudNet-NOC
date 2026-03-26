# Runbook: RDS Failover

**Service:** CloudNet RDS (`CloudNet-MySQL-Primary`)  
**Severity:** Critical  
**Last Updated:** 2026-03-26  
**Author:** Sarweshwar Patel  

---

## Symptoms

- Application returning database connection errors
- RDS primary instance status shows **Failing over** or **Rebooting**
- CloudWatch alarm `RDS-FreeStorageSpace` or `RDS-CPUUtilization` triggered
- Read replica lag spiking or replica disconnected

---

## Impact

- Full database write unavailability during failover (~60-120 seconds)
- Application errors for all DB-dependent requests
- Read replica may also be temporarily unavailable

---

## Diagnosis Steps

**Step 1 — Check RDS Status**
1. **RDS** → **Databases** → Select `CloudNet-MySQL-Primary`
2. Check **Status** column — look for: `Available`, `Failing-over`, `Rebooting`
3. **Connectivity & security** tab → Note the current **Endpoint** (may change after failover)

**Step 2 — Check Multi-AZ Status**
1. On the same RDS details page → **Configuration** tab
2. Confirm **Multi-AZ: Yes**
3. If failover is in progress, status will show the standby being promoted

**Step 3 — Check CloudWatch Metrics**
1. **CloudWatch** → **Dashboards** → `CloudNet-Dashboard`
2. Check: `DatabaseConnections`, `FreeStorageSpace`, `CPUUtilization`, `ReplicaLag`
3. Identify spike pattern — storage full vs CPU overload vs network issue

**Step 4 — Check Application Connection String**
1. Confirm app is using the **RDS Endpoint DNS name** (not hardcoded IP)
2. DNS will automatically point to the new primary after failover
3. If app uses hardcoded IP — this is the root cause, update to DNS endpoint

---

## Resolution

| Scenario | Fix |
|---|---|
| Automatic failover in progress | Wait 60-120 seconds, Multi-AZ handles it |
| Storage full | **Modify** RDS → increase storage (auto-scaling should prevent this) |
| High CPU | Check slow queries in **Performance Insights** |
| App hardcoded IP | Update connection string to use RDS DNS endpoint |
| Read replica lagging | Check replica status, restart if needed |

**Manual failover (if needed):**
1. **RDS** → Select primary → **Actions** → **Reboot** → ✅ **Reboot with failover**
2. Wait for standby to become new primary (~60 sec)

---

## Post-Incident

- Confirm new primary is in different AZ from original
- Verify read replica reconnected and lag is 0
- Update incident log with failover duration
- Review Performance Insights for root cause query
