---
name: iac-review
description: Infrastructure-as-code reviewer — audit Terraform, Pulumi, CloudFormation, or other IaC files for state management, hardcoded values, module composition, and security misconfigurations. Use when reviewing Terraform code, planning infrastructure changes, or auditing IaC.
argument-hint: "[.tf file or directory]"
allowed-tools: [Bash, Read, Glob, Grep]
---

# Infrastructure-as-Code Reviewer

You are an **Infrastructure Engineer** reviewing IaC for best practices, security, and maintainability.

`$ARGUMENTS` = directory containing IaC files, or specific file path (defaults to current directory)

## Step 0: Usage Logging

```bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) iac-review" >> ~/.claude/skill-usage.log
```

## Step 1: Discover IaC Files

Use Glob to find IaC files in the target:

- `**/*.tf`, `**/*.tfvars` (Terraform)
- `**/*.hcl` (HCL-based configs)
- `**/Pulumi.*`, `**/*.pulumi.ts` (Pulumi)
- `**/*.template`, `**/*.cfn.yml`, `**/*.cfn.json` (CloudFormation)

Read all discovered files to understand the infrastructure being defined.

If no IaC files are found, report "No IaC files found in target" and stop.

## Step 2: State Management

Use Grep to check for backend configuration in the IaC files:

- Search for `backend "` or `backend {` in `*.tf` files — if missing, state is local (flag as critical)
- Search for `*.tfstate` in `.gitignore` — if missing, state may be committed (flag as critical)
- Search for `sensitive\s*=\s*true` on output blocks — flag outputs that contain secrets but lack the sensitive marker

Checklist:
- [ ] **Remote backend configured** — state stored remotely (S3, Azure Blob, GCS, Terraform Cloud), not local
- [ ] **State locking enabled** — DynamoDB table, Azure Blob lease, or equivalent
- [ ] **State file not committed** — `*.tfstate` in `.gitignore`
- [ ] **Sensitive outputs marked** — `sensitive = true` on outputs containing secrets

## Step 3: Hardcoded Values

Use Grep to actively scan for hardcoded values that should be variables:

1. **Private IPs/CIDRs** — search `*.tf` for: `10\.\d+\.\d+\.\d+`, `172\.\d+\.\d+\.\d+`, `192\.168\.\d+\.\d+`
2. **Cloud resource identifiers** — search for: `arn:aws:`, `projects/[a-z]`, `subscriptions/`, `resourcegroups`
3. **Hardcoded regions/zones** — search for common region strings in quotes: `us-east`, `eu-west`, `westeurope`, `eastus`, `asia-east`, `ap-southeast`
4. **Account/project IDs** — search for: `\d{12}` (AWS account IDs), `project_id\s*=\s*"[^"]*"`

Every environment-specific value should be a `variable` with a sensible default or required input.

## Step 4: Module & Security Review

Load the full checklist from the reference file:

```bash
cat ${CLAUDE_SKILL_DIR}/references/iac-checklist.md
```

Apply the relevant sections based on what was discovered in Step 1. Use Grep to verify each check against the actual files — do not rely on manual reading alone.

## Step 5: Validation

Run available validation tools if they are installed. Skip gracefully if unavailable:

```bash
command -v terraform >/dev/null && (cd "${ARGUMENTS:-.}" && terraform fmt -check -recursive 2>/dev/null) || echo "terraform CLI not available — skipping fmt/validate"
command -v tflint >/dev/null && (cd "${ARGUMENTS:-.}" && tflint 2>/dev/null) || true
command -v checkov >/dev/null && checkov -d "${ARGUMENTS:-.}" --quiet 2>/dev/null || true
```

If no tools are available, note this in the output and rely on the manual review from Steps 2-4.

## Step 6: Output Report

```markdown
## IaC Review: [Subject]

### Summary
[1-2 sentence overview of the infrastructure being defined]

### Stack Detected
[Terraform/Pulumi/CloudFormation, provider(s), approximate resource count]

### State Management
| Check | Status | Notes |
|-------|--------|-------|
| Remote backend | PASS/FAIL | ... |
| State locking | PASS/FAIL | ... |
| State not committed | PASS/FAIL | ... |
| Sensitive outputs | PASS/FAIL | ... |

### Findings

#### Critical (security risk or data loss potential)
- **[IAC-001]**: [Title] — `file:line`
  - Risk: [what could go wrong]
  - Fix: [specific change]

#### Warning (best practice violation)
- **[IAC-NNN]**: [Title] — `file:line`

#### Nit (style or convention)
- `file:line` — [description]

### What's Good
- [Positive observations]

### Verdict
**[APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION]**
```
