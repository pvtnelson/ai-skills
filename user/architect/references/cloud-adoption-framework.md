# Cloud Adoption Framework (CAF)

Reference for the `/architect` skill. Evaluate architecture decisions against these six pillars when the system targets cloud deployment.

## Strategy

Define the business justification and expected outcomes before choosing technology.

- **Motivations** — what drives the move? Cost reduction, scalability, compliance, agility?
- **Business outcomes** — measurable targets (latency SLAs, uptime %, cost per transaction)
- **Business case** — ROI analysis: current cost vs projected cloud cost including migration effort
- **First project selection** — start with low-risk, high-learning workloads (not mission-critical)

### Architect checklist
- [ ] Business outcome is defined and measurable
- [ ] Success criteria exist before implementation starts
- [ ] Stakeholders agree on the "why" — not just the "what"

## Plan

Assess the current estate and build a cloud adoption plan.

- **Digital estate assessment** — inventory all workloads, classify by migration strategy:
  - **Rehost** (lift-and-shift) — move as-is to IaaS
  - **Refactor** — minor changes for PaaS compatibility
  - **Rearchitect** — redesign for cloud-native (containers, serverless)
  - **Rebuild** — rewrite from scratch when legacy is unmaintainable
  - **Replace** — swap for SaaS (e.g., self-hosted email → M365)
- **Skills readiness** — does the team know Terraform, Kubernetes, CI/CD, observability?
- **Adoption plan** — phased timeline with dependencies, not a big-bang migration

### Architect checklist
- [ ] Each workload has a migration strategy (rehost/refactor/rearchitect/rebuild/replace)
- [ ] Skills gaps are identified with a learning plan
- [ ] Migration phases are sequenced by dependency and risk

## Ready

Prepare the landing zone — the foundational cloud environment.

- **Landing zone** — base infrastructure: networking, identity, subscription/account structure, policies
- **Naming & tagging** — consistent resource naming convention and cost-allocation tags
- **Network topology** — hub-spoke, mesh, or flat? VPN/ExpressRoute/peering for hybrid
- **Identity** — centralized IAM, RBAC, least-privilege, MFA everywhere
- **Governance baseline** — policies enforced at deployment time (allowed regions, SKUs, encryption)

### Architect checklist
- [ ] Landing zone is codified (Terraform/Bicep/Pulumi), not click-ops
- [ ] Naming convention documented and enforced by policy
- [ ] Network segmentation follows least-privilege (no flat networks)
- [ ] Identity federation configured (SSO, no local accounts)
- [ ] Tagging policy enforced for cost tracking

## Adopt

Execute the migration or innovation workstream.

### Migrate
- **Assess** — discover dependencies, performance baselines, compatibility
- **Deploy** — provision target environment, replicate data, cutover
- **Release** — validate, performance test, enable monitoring, go live

### Innovate
- **Build** — cloud-native: containers, serverless, event-driven, microservices
- **Measure** — hypothesis-driven development, feature flags, A/B testing
- **Learn** — feedback loops, telemetry, iterate fast

### Architect checklist
- [ ] Migration has a rollback plan (not just a cutover plan)
- [ ] Data migration is tested with production-scale data
- [ ] New cloud-native components follow 12-factor principles
- [ ] CI/CD pipeline deploys to cloud target (no manual deployments)

## Govern

Maintain compliance, cost control, and security posture.

- **Cost management** — budgets, alerts, reserved instances, right-sizing recommendations
- **Security baseline** — encryption at rest/in transit, key management, vulnerability scanning
- **Policy compliance** — regulatory requirements (GDPR, SOC2, ISO 27001) mapped to controls
- **Resource consistency** — Infrastructure as Code, drift detection, no manual changes
- **Identity baseline** — access reviews, PIM/PAM, service principal hygiene

### Architect checklist
- [ ] Cost alerts configured with budget thresholds
- [ ] All data encrypted at rest and in transit
- [ ] IaC is the only path to production (no portal/CLI ad-hoc changes)
- [ ] Compliance controls are automated, not documented-only
- [ ] Access is reviewed periodically (not set-and-forget)

## Manage

Operate the cloud environment reliably.

- **Business commitments** — SLAs, SLOs, SLIs defined per workload
- **Operations baseline** — monitoring, alerting, incident response, runbooks
- **Platform operations** — patching, scaling, backup/restore, disaster recovery
- **Workload operations** — application-level health checks, performance baselines, capacity planning

### Architect checklist
- [ ] SLOs defined with error budgets (not just "five nines")
- [ ] Monitoring covers infrastructure AND application layer
- [ ] Alerting has clear escalation paths and runbooks
- [ ] DR tested (not just documented) — RTO/RPO validated
- [ ] Backup restore tested regularly
