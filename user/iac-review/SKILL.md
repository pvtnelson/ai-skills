---
name: iac-review
description: Terraform infrastructure code reviewer — audit .tf files for state management, hardcoded values, module composition, and security misconfigurations. Use when reviewing Terraform code or planning infrastructure changes.
argument-hint: "[.tf file or directory]"
allowed-tools: [Bash, Read, Glob, Grep]
---

# Terraform / IaC Reviewer

You are an **Infrastructure Engineer** reviewing Terraform code for best practices, security, and maintainability.

`$ARGUMENTS` = directory containing .tf files, or specific file path (defaults to current directory)

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) iac-review" >> ~/.claude/skill-usage.log
```

## Review Process

## Step 1: Discover Terraform Files

```bash
find "${ARGUMENTS:-.}" -name "*.tf" -o -name "*.tfvars" | sort
```

Read all `.tf` files to understand the infrastructure being defined.

## Step 2: State Management

- [ ] **Remote backend configured** — state stored in a remote backend (S3, Azure Blob, GCS, Terraform Cloud), not local
- [ ] **State locking enabled** — DynamoDB table, Azure Blob lease, or equivalent
- [ ] **State file not committed** — `*.tfstate` in `.gitignore`
- [ ] **Sensitive outputs marked** — `sensitive = true` on outputs containing secrets

## Step 3: Hardcoded Values

Scan for hardcoded values that should be variables:

```bash
# Hardcoded IPs, CIDRs, ARNs, resource IDs
grep -rn --include="*.tf" -E '(10\.\d+\.\d+\.\d+|172\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+)' "${ARGUMENTS:-.}" || true
grep -rn --include="*.tf" -E 'arn:aws:|projects/[a-z]|subscriptions/' "${ARGUMENTS:-.}" || true

# Hardcoded regions, zones, account IDs
grep -rn --include="*.tf" -E '"(us-east-1|eu-west-1|westeurope|eastus)"' "${ARGUMENTS:-.}" || true
```

Every environment-specific value should be a `variable` with a sensible default or required input.

## Step 4: Module Composition

- [ ] **Modules used for reuse** — repeated resource patterns extracted into modules
- [ ] **Module sources pinned** — version constraints on registry modules (`version = "~> 3.0"`)
- [ ] **Module interfaces clean** — inputs are typed with descriptions, outputs documented
- [ ] **No circular dependencies** — modules reference each other cleanly
- [ ] **Root module is thin** — orchestrates modules, minimal direct resource definitions

## Step 5: Security Misconfigurations

- [ ] **No public access by default** — S3 buckets, storage accounts, databases are private unless explicitly justified
- [ ] **Encryption enabled** — storage, databases, and secrets use encryption at rest
- [ ] **Network restrictions** — security groups / NSGs follow least-privilege (no `0.0.0.0/0` ingress on sensitive ports)
- [ ] **IAM least privilege** — roles and policies grant minimum required permissions
- [ ] **No secrets in .tf files** — passwords, keys, tokens are sourced from vault or variables (never hardcoded)
- [ ] **Logging enabled** — CloudTrail, Azure Monitor, or equivalent configured for audit trail

## Step 6: Code Quality

- [ ] **Consistent naming** — resources follow a naming convention (`project-env-resource`)
- [ ] **Descriptions on variables** — all `variable` blocks have `description`
- [ ] **Type constraints** — variables have `type` defined
- [ ] **Lifecycle rules** — `prevent_destroy` on critical resources (databases, DNS zones)
- [ ] **Tags/labels** — all resources tagged with at minimum: environment, project, owner
- [ ] **Formatting** — `terraform fmt` compliant

## Step 7: Validation

Run available validation tools:

```bash
cd "${ARGUMENTS:-.}"
terraform fmt -check -recursive 2>/dev/null || echo "terraform fmt check failed or not available"
terraform validate 2>/dev/null || echo "terraform validate failed or not initialized"
```

## Step 8: Output Format

```markdown
## IaC Review: [Subject]

### Summary
[1-2 sentence overview of the infrastructure being defined]

### State Management
[PASS / FAIL — details]

### Findings

#### Critical (security risk or data loss potential)
- `file:line` — [description]

#### Warning (best practice violation)
- `file:line` — [description]

#### Nit (style or convention)
- `file:line` — [description]

### What's Good
- [Positive observations]

### Verdict
**[APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION]**
```
