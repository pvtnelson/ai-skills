# Infrastructure & Configuration Security Checklist

Apply only the sections that match the technologies detected during reconnaissance.

## Container Images (Dockerfile, Containerfile)
- [ ] Base image pinned to digest or specific version (not `:latest`)
- [ ] `USER` directive present — container does not run as root
- [ ] No secrets in `ENV`, `ARG`, or `COPY` (use runtime mounts or secrets management)
- [ ] Multi-stage build to minimize final image attack surface
- [ ] `.dockerignore` excludes `.env`, `.git`, `node_modules`, secrets
- [ ] `HEALTHCHECK` defined for service containers
- [ ] No `--privileged`, `SYS_ADMIN`, or unnecessary capabilities
- [ ] Package manager cache cleared after install

## Container Orchestration (Compose, Swarm, Kubernetes, Nomad)
- [ ] No privileged mode unless absolutely required
- [ ] Secrets not in environment variable definitions (use platform secrets management)
- [ ] Networks segmented (not all services on a shared default network)
- [ ] Ports bound to localhost where external access is not needed
- [ ] Volume mounts do not expose sensitive host directories
- [ ] Images pinned to specific versions
- [ ] Resource limits set (CPU, memory) to prevent DoS
- [ ] Pod/container security context restricts root, host namespaces, capabilities
- [ ] Read-only root filesystem where possible
- [ ] Network policies restrict inter-service communication to what is needed

## IaC Provisioning (Terraform, Pulumi, CloudFormation, Bicep, CDK)
- [ ] State/backend uses encryption at rest
- [ ] State/backend has access control (not publicly accessible)
- [ ] State files not committed to git (check .gitignore)
- [ ] No hardcoded credentials in provider/resource definitions
- [ ] Provider and module versions pinned with constraints
- [ ] Modules sourced from trusted registries
- [ ] Firewall/security groups: no 0.0.0.0/0 ingress on management or database ports
- [ ] Storage resources not publicly accessible by default
- [ ] Database instances have encryption at rest and are not publicly exposed
- [ ] Logging and audit trails enabled on network, compute, and storage resources
- [ ] Key management keys have rotation enabled
- [ ] IAM/RBAC policies follow least privilege (no wildcard actions/resources)
- [ ] Plan/preview output reviewed before apply (no auto-approve in CI)

## Configuration Management (Ansible, Chef, Puppet, Salt)
- [ ] Vault or encrypted variables for secrets (no plaintext in playbooks/recipes)
- [ ] SSH keys and credentials not embedded in repositories
- [ ] Roles and modules sourced from trusted sources with version pins
- [ ] Privilege escalation (sudo/become) limited to specific tasks
- [ ] Idempotent operations — no destructive side effects on re-run

## CI/CD Pipelines (GitHub Actions, GitLab CI, Jenkins, CircleCI, Azure Pipelines)
- [ ] Secrets accessed via platform secrets manager, never hardcoded in config
- [ ] Third-party plugins/actions pinned to SHA or specific version (not `@latest`)
- [ ] Pipeline permissions follow least privilege (scoped tokens, minimal write access)
- [ ] PR-triggered workflows do not checkout untrusted code with elevated permissions
- [ ] Self-hosted runners not exposed to untrusted workflows
- [ ] Build artifacts do not contain secrets or credentials
- [ ] OIDC/workload identity used for cloud auth (not long-lived static keys)
- [ ] Branch protection requires reviews and status checks before merge

## TLS & Certificate Configuration
- [ ] TLS 1.2+ enforced (no SSLv3, TLS 1.0, TLS 1.1)
- [ ] Strong cipher suites only (no RC4, DES, 3DES, export ciphers)
- [ ] HSTS headers configured with adequate max-age
- [ ] Certificate validity and auto-renewal verified
- [ ] Certificate verification not disabled in application code (`verify=False`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, `InsecureSkipVerify`)
- [ ] Internal services use mutual TLS or private CA where appropriate

## Cloud-Specific (apply per detected provider)
- [ ] No public S3/GCS/Blob storage unless intentionally static hosting
- [ ] CloudTrail/Activity Log/Audit Log enabled
- [ ] Default VPC/network not used for production workloads
- [ ] Managed database instances enforce encryption in transit
- [ ] IAM users prefer roles/service accounts over long-lived access keys
