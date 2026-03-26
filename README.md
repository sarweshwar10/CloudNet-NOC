# CloudNet-NOC
Production-grade AWS cloud network — Console + Terraform

Project CloudNet: Engineering a Zero Trust AWS Ecosystem
Building in the cloud is easy, but building a network that can actually survive a breach is where it gets interesting. I created CloudNet to move beyond standard configurations and implement a true Zero Trust architecture that assumes breach and verifies every transaction.

Architectural Vision
This project demonstrates a professional Hub-and-Spoke network topology designed for isolation and scale. By separating workloads into distinct VPCs and tiers, I have effectively isolated critical data from public-facing threats.

Network Segmentation: I utilized a 10.10.0.0/16 CIDR for the HQ and 10.20.0.0/16 for the Branch to ensure no IP overlaps during connectivity.

Tiered Security: The environment is split into Public, Private, and Database tiers across two Availability Zones for maximum fault tolerance.

Hybrid Connectivity: Established a secure Site-to-Site VPN between the HQ and a simulated branch office using IPSec tunnels.

Security Hardening
I focused heavily on the Principle of Least Privilege to ensure that every component only has the access it absolutely needs.

Identity over Open Ports: I transitioned to AWS Systems Manager (SSM) for management, meaning I could finally close Port 22 (SSH) for good.

Layered Firewalls: I combined stateless Network ACLs at the subnet level with stateful Security Groups at the instance level for defense-in-depth.

Data Protection: Every byte of data is guarded by account-level S3 Block Public Access, and all databases are encrypted at rest using AWS KMS.

Operations and Observability
You cannot defend what you cannot see. I built a centralized CloudNet-NOC Dashboard to monitor the real-time heartbeat of the system.

Real-time Telemetry: Tracking EC2 CPU usage, ALB request counts, and RDS connection patterns.

Proactive Guardrails: Automated CloudWatch Alarms are set to trigger email notifications for high CPU usage, database storage limits, or spikes in ALB 5xx errors.

Full Audit Trail: Every API call is logged via CloudTrail, while VPC Flow Logs capture every packet attempt for forensic analysis.

Resilience and Chaos Engineering
To prove the architecture strength, I performed several experiments to verify recovery capabilities:

Instance Auto-Recovery: Manually terminated an application instance, and the Auto Scaling Group (ASG) automatically launched a replacement within minutes.

Database Failover: Forced a failover of the primary RDS instance; the Multi-AZ standby was promoted to primary seamlessly to maintain connectivity.

Repository Contents
/Runbooks: Step-by-step guides for handling VPN outages, RDS failovers, and cost spikes.

/ADRs: Architectural Decision Records explaining the logic behind CIDR selection, TGW vs. Peering, and SSM over SSH.

/Images: Complete visual documentation of the AWS Console configuration.

