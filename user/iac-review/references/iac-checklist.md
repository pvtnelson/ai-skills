# IaC Review Checklist

Apply only the sections relevant to the detected IaC stack.

## Module Composition (Terraform / Pulumi)
- [ ] **Modules used for reuse** — repeated resource patterns extracted into modules
- [ ] **Module sources pinned** — version constraints on registry modules (`version = "~> 3.0"`)
- [ ] **Module interfaces clean** — inputs are typed with descriptions, outputs documented
- [ ] **No circular dependencies** — modules reference each other cleanly
- [ ] **Root module is thin** — orchestrates modules, minimal direct resource definitions

## Security Misconfigurations
- [ ] **No public access by default** — storage buckets, databases, VMs are private unless explicitly justified
- [ ] **Encryption enabled** — storage, databases, and secrets use encryption at rest
- [ ] **Network restrictions** — security groups / NSGs follow least-privilege (no `0.0.0.0/0` ingress on SSH, RDP, or database ports)
- [ ] **IAM least privilege** — roles and policies grant minimum required permissions (no wildcard `*` actions/resources)
- [ ] **No secrets in IaC files** — passwords, keys, tokens sourced from vault or variables (never hardcoded)
- [ ] **Logging enabled** — CloudTrail, Azure Monitor, GCP Audit Logs, or equivalent configured

## Code Quality
- [ ] **Consistent naming** — resources follow a naming convention (`project-env-resource`)
- [ ] **Descriptions on variables** — all `variable` blocks have `description`
- [ ] **Type constraints** — variables have `type` defined
- [ ] **Lifecycle rules** — `prevent_destroy` on critical resources (databases, DNS zones, encryption keys)
- [ ] **Tags/labels** — all resources tagged with at minimum: environment, project, owner
- [ ] **Formatting** — `terraform fmt` compliant (or equivalent for other tools)

## Provider & Dependency Management
- [ ] **Provider versions pinned** — `required_providers` with version constraints
- [ ] **Terraform/tool version pinned** — `required_version` set
- [ ] **Lock file committed** — `.terraform.lock.hcl` in version control for reproducible builds
- [ ] **No deprecated resources** — check for resources marked deprecated in provider docs

## Operational Readiness
- [ ] **Outputs defined** — key values (IDs, endpoints, connection strings) available as outputs
- [ ] **Data sources preferred** — reference existing resources via `data` blocks, not hardcoded IDs
- [ ] **Workspaces or environments** — clear strategy for dev/staging/prod separation
- [ ] **Plan reviewed before apply** — no `auto-approve` in CI pipelines
