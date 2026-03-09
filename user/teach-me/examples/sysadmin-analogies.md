# SysAdmin → Cloud-Native Analogies

This is a **domain-specific variant** of `references/analogies.md` for users transitioning from traditional SysAdmin/Linux administration to Cloud-Native and DevOps roles.

## How to Use

1. **To activate**: copy this file to `references/analogies.md` (replacing the generic version), or merge the rows you want into the existing file
2. **During teaching**: the skill loads `references/analogies.md` automatically — every analogy maps a cloud-native concept to a Linux/SysAdmin equivalent the user already knows
3. **Extend it**: add rows for tools and concepts specific to your environment (e.g., your monitoring stack, your configuration management tool)

## How the Analogies Work

Each row follows this pattern:

| Cloud-Native Concept | SysAdmin Equivalent | Where the Analogy Breaks Down |
|---|---|---|

**When teaching**, use the SysAdmin equivalent to explain the concept, then immediately call out the key difference so the user builds accurate mental models.

---

## Containers & Docker

| Cloud-Native | SysAdmin Equivalent | Key Difference |
|---|---|---|
| Container | `chroot` jail with cgroups | Containers share the host kernel but have isolated filesystem, PID, and network namespaces |
| Dockerfile | Kickstart / Preseed / shell provisioning script | Declarative and layered — each instruction creates a cached, immutable layer |
| Docker image | Golden image / VM template | Layered and content-addressable — layers are shared and deduplicated |
| `ENTRYPOINT` + `CMD` | Init system (PID 1 process) | Container exits when this process exits — no init system keeping it alive |
| Docker volume | Bind mount / NFS share | Data persists beyond container lifecycle, like mounting `/data` from shared storage |
| `docker-compose` | Multi-service init scripts (systemd units) | Defines an entire stack declaratively — like writing all your `.service` files in one place |
| Multi-stage build | Build server → deploy artifact | Compile in a fat image, copy only the binary to a minimal runtime image |

### Example usage in teaching

> **Concept**: Container
> **What you say**: "You know `chroot`? It gives a process its own root filesystem. A container is that idea taken further — it also isolates PIDs, network interfaces, and user IDs using Linux namespaces, and limits CPU/memory with cgroups. But unlike a VM, there's no separate kernel — it's all running on the host kernel."
> **Then ask**: "If containers share the host kernel, what happens if a container tries to load a kernel module? And what does that mean for running Windows containers on a Linux host?"

## Kubernetes

| Cloud-Native | SysAdmin Equivalent | Key Difference |
|---|---|---|
| Pod | A VM running one main process | Smallest schedulable unit — usually 1 container, but can co-locate sidecars |
| Deployment | Managed service group with rolling restarts | Declarative desired state — K8s reconciles to match, like a self-healing systemd |
| Service (ClusterIP) | Internal DNS + load balancer (HAProxy/Nginx upstream) | Stable virtual IP that routes to healthy pods automatically |
| Ingress | Nginx reverse proxy with vhost routing | Maps external HTTP(S) traffic to internal services by hostname/path |
| ConfigMap | `/etc/` config files distributed via Puppet/Ansible | Decouples config from the application image — mount as files or inject as env vars |
| Secret | `/etc/shadow` or Vault-managed credentials | Base64-encoded (not encrypted!) by default — treat like sensitive files with strict permissions |
| Namespace | Separate environments on the same physical server | Logical isolation of resources — like having `dev/`, `staging/`, `prod/` directories |
| PersistentVolume | SAN/NAS LUN attached to a server | Storage that outlives pods — requested via PersistentVolumeClaim (like a storage request ticket) |
| HPA | Auto-scaling group triggered by monitoring | Scales pods based on metrics — HPA watches CPU/memory, KEDA watches custom metrics like queue depth |
| DaemonSet | Agent installed on every node (like node_exporter) | Guarantees exactly one pod per node — perfect for log collectors, monitoring agents |
| CronJob | Crontab entry | Scheduled pod execution — like cron but with retry policies and concurrency control |

### Example usage in teaching

> **Concept**: Deployment
> **What you say**: "Think of a Deployment like a systemd service with `Restart=always` and a configurable replica count. You declare 'I want 3 instances of this process' and Kubernetes keeps that true — if a node dies, it reschedules the pod elsewhere. It's like systemd, but cluster-wide instead of single-machine."
> **Then ask**: "A Deployment has four top-level keys. You need `apiVersion`, `kind`, `metadata`, and `spec`. The `apiVersion` for Deployments is NOT `v1` — it lives in an API group. Check the Kubernetes docs: what API group do Deployments belong to?"

## CI/CD & GitOps

| Cloud-Native | SysAdmin Equivalent | Key Difference |
|---|---|---|
| GitHub Actions workflow | Jenkins pipeline / cron + shell scripts | Event-driven (push, PR, schedule) — declarative YAML instead of imperative scripts |
| Container registry (GHCR) | Artifact repository / package mirror | Stores versioned, immutable images — like an RPM/APT repo but for containers |
| Terraform | Ansible but for cloud resources | Declarative desired state with a state file — plans before applying, tracks what exists |
| Terraform state | CMDB / inventory file | Records what Terraform manages — drift detection compares state to reality |
| Helm chart | RPM/DEB package for Kubernetes | Templated K8s manifests with variables — like parameterized Ansible roles |

### Example usage in teaching

> **Concept**: GitHub Actions
> **What you say**: "You know how cron reads from `/etc/cron.d/` — specific directories with specific file formats? GitHub Actions works the same way. There's one exact directory path in your repo where GitHub looks for pipeline definitions, and the files must be YAML."
> **Then ask**: "What's the full path where you'd create a CI workflow file? It starts with `.github/`..."

## Networking

| Cloud-Native | SysAdmin Equivalent | Key Difference |
|---|---|---|
| VPC | VLAN / isolated network segment | Software-defined network with full control over subnets, routing, and ACLs |
| Security Group | `iptables` / `firewalld` rules | Stateful firewall attached to instances — defined by allow rules only (implicit deny) |
| Load Balancer (cloud) | HAProxy / Nginx in front of app servers | Managed service — no server to maintain, auto-scales, health checks built in |
| Service Mesh (Istio) | Mutual TLS + mTLS between services via stunnel | Sidecar proxies handle encryption, retries, circuit breaking — app code doesn't change |

## Observability

| Cloud-Native | SysAdmin Equivalent | Key Difference |
|---|---|---|
| Prometheus | Nagios/Zabbix with pull-based collection | Scrapes metrics endpoints — apps expose `/metrics` instead of pushing to a central server |
| Grafana dashboard | Cacti / Munin graphs | Flexible query-based visualization — dashboards-as-code via JSON provisioning |
| Structured logging (JSON) | Syslog with parseable format | Machine-readable from the start — no regex parsing needed, fields are first-class |
| Health probe (liveness/readiness) | Monitoring check (HTTP 200 / port open) | Built into the orchestrator — K8s restarts unhealthy pods automatically |
