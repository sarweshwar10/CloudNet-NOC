# Runbook: High 5xx Error Rate

**Service:** CloudNet ALB (`CloudNet-ALB`) + App Servers  
**Severity:** High  
**Last Updated:** 2026-03-26  
**Author:** Sarweshwar Patel  

---

## Symptoms

- CloudWatch alarm `ALB-5xx-High` triggered
- ALB metric `HTTPCode_Target_5XX_Count` elevated
- Users reporting 502, 503, or 504 errors
- CloudFront returning error pages

---

## Impact

- Partial or full application unavailability
- ALB health checks failing → instances being deregistered from target group
- Auto Scaling may be launching new instances in response

---

## Diagnosis Steps

**Step 1 — Check ALB Target Group Health**
1. **EC2** → **Target Groups** → Select `CloudNet-App-TG`
2. **Targets** tab → Check health status of each instance
3. Look for: `Unhealthy`, `Draining`, or `Unused` instances

**Step 2 — Identify Error Type**
| Error Code | Likely Cause |
|---|---|
| 502 Bad Gateway | App server not responding on port 80 |
| 503 Service Unavailable | No healthy targets in target group |
| 504 Gateway Timeout | App server responding too slowly |

**Step 3 — Check EC2 Instance Health**
1. **EC2** → **Instances** → Check App Server status checks
2. If **2/2 checks failed** → instance needs replacement
3. **Auto Scaling Groups** → `CloudNet-App-ASG` → **Activity** tab → check for recent scaling events

**Step 4 — Check Apache/App Logs via SSM**
1. **EC2** → Select healthy instance → **Connect** → **Session Manager**
2. Run: `sudo tail -100 /var/log/httpd/error_log`
3. Look for OOM errors, connection refused, or disk full messages

**Step 5 — Check CloudWatch Metrics**
1. `CPUUtilization` — if >90%, app is overloaded
2. `NetworkIn/Out` — unexpected traffic spike?
3. `StatusCheckFailed` — instance hardware issue?

---

## Resolution

| Scenario | Fix |
|---|---|
| All instances unhealthy | Check ASG — new instances should be launching |
| Single instance unhealthy | Terminate it — ASG will replace automatically |
| App process crashed | SSM → `sudo systemctl restart httpd` |
| CPU overloaded | Temporarily increase ASG max capacity |
| Disk full | SSM → `df -h` → clear logs or increase EBS volume |

**Force ASG to replace instance:**
1. **EC2** → **Auto Scaling Groups** → `CloudNet-App-ASG`
2. **Instance management** tab → Select unhealthy instance → **Detach** → ✅ Replace with new instance

---

## Post-Incident

- Confirm all targets in `CloudNet-App-TG` show **Healthy**
- Verify ALB 5xx count returns to 0 in CloudWatch
- Document root cause and fix in incident log
- Review ASG scaling policy — consider adding scale-out alarm on 5xx rate
