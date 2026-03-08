# Architecture Design Principles

Reference for the `/architect` skill. Apply these principles when evaluating or proposing system designs.

## Well-Architected Framework (5 Pillars)

### 1. Reliability
Design for failure — everything fails, plan for it.

- **Redundancy** — no single points of failure in critical paths
- **Self-healing** — automatic recovery (health checks, restart policies, circuit breakers)
- **Blast radius** — failures are contained (bulkheads, isolation boundaries)
- **Testing** — chaos engineering, failure injection, game days
- **Data durability** — backups tested, replication configured, RPO defined

Questions to ask:
- What happens when this component dies at 3 AM?
- How long until someone notices? How long until it's fixed?
- Can partial failure still serve users (degraded mode)?

### 2. Security
Defense in depth — never rely on a single layer.

- **Zero trust** — verify explicitly, least-privilege, assume breach
- **Identity-first** — authentication before authorization, MFA, no shared credentials
- **Encryption** — at rest (AES-256), in transit (TLS 1.2+), in use where possible
- **Network segmentation** — microsegmentation, private endpoints, no public IPs unless required
- **Supply chain** — dependency scanning, SBOM, signed artifacts, pinned versions
- **Secrets management** — vault/KMS, never in code/config/env files, rotated automatically

Questions to ask:
- If an attacker compromises this component, what's the blast radius?
- Are secrets rotatable without downtime?
- Could a malicious dependency compromise the build pipeline?

### 3. Cost Optimization
Spend money intentionally — not accidentally.

- **Right-sizing** — match resource allocation to actual usage (not peak guesses)
- **Auto-scaling** — scale to demand, scale to zero when idle
- **Reserved capacity** — commit where usage is predictable (1yr/3yr)
- **Storage tiers** — hot/cool/archive based on access patterns
- **Observability** — you can't optimize what you can't measure (cost per request, cost per user)

Questions to ask:
- What does this cost per month at current scale? At 10x?
- Is anything running 24/7 that could be on-demand?
- Are we paying for capacity we're not using?

### 4. Operational Excellence
Automate everything — humans are for decisions, not procedures.

- **Infrastructure as Code** — every environment reproducible from git
- **CI/CD** — automated build, test, deploy (no SSH-and-pray deployments)
- **Observability** — logs, metrics, traces (the three pillars)
- **Runbooks** — every alert has a documented response procedure
- **Post-mortems** — blameless, focused on systemic fixes, not individual blame

Questions to ask:
- Can a new team member deploy to production on day one?
- If you deleted the environment, could you rebuild it from code?
- Are alerts actionable or just noise?

### 5. Performance Efficiency
Use resources efficiently — match technology to workload characteristics.

- **Caching** — reduce repeated computation (CDN, application cache, query cache)
- **Async processing** — queues for work that doesn't need immediate response
- **Connection pooling** — reuse database/HTTP connections
- **Data locality** — compute near data, edge for users
- **Right tool** — SQL for relational, NoSQL for documents, queues for messaging, blob for files

Questions to ask:
- Where are the latency bottlenecks? Are they inherent or fixable?
- Is the database doing work the application should do (or vice versa)?
- Would a CDN/cache eliminate 80% of the load?

## General Design Principles

### KISS (Keep It Simple)
The best architecture is the simplest one that meets requirements. Complexity is a cost — every moving part is a failure point, a maintenance burden, and a thing to learn.

- Prefer managed services over self-hosted
- Prefer monolith over microservices until you have a reason to split
- Prefer boring technology over cutting-edge (unless cutting-edge solves a real problem)

### YAGNI (You Aren't Gonna Need It)
Design for current requirements plus one step ahead — not three. Premature abstraction is worse than duplication.

### Separation of Concerns
Each component has one job. Data access, business logic, and presentation are separate. Infrastructure and application concerns are separate.

### Loose Coupling
Components communicate through well-defined interfaces (APIs, events, queues). Changing one component doesn't require changing another. Prefer async communication where possible.

### Immutability
Servers, containers, and infrastructure are replaced, not modified. No SSH to fix production. No in-place upgrades. Build new, swap traffic, tear down old.

### Observability by Default
If you can't observe it, you can't operate it. Every service emits structured logs, exposes metrics, and participates in distributed tracing. Monitoring is not an afterthought — it's a launch requirement.
