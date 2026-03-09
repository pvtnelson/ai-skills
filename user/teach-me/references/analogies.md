# Concept Analogies Reference

This file is loaded by the `/teach-me` skill during Step 3a to find relevant analogies.

## How to Use This File

1. **During teaching**: when explaining a concept, scan the tables below for a matching row
2. **If a match exists**: use the "Analogy" column to explain the concept, then highlight the "Key Difference" so the user understands where the analogy breaks down
3. **If no match exists**: create an analogy on the fly using the same pattern — map the new concept to something concrete the user already knows
4. **Customization**: add your own rows for concepts specific to your domain or background

## How to Customize

This is the **generic** analogy set. To tailor it for your background:

- **SysAdmin background?** See `examples/sysadmin-analogies.md` for Linux/networking-anchored analogies (chroot → container, systemd → Deployment, iptables → Security Group)
- **Frontend developer?** Add analogies like: Kubernetes Service → API gateway / reverse proxy you'd configure in Next.js rewrites
- **Data engineer?** Add analogies like: Kubernetes Job → Airflow task, ConfigMap → environment config in dbt profiles.yml

Copy the example file to `references/analogies.md` and extend it, or add rows directly below.

---

## Containers & Docker

| Concept | Analogy | Key Difference |
|---|---|---|
| Container | Lightweight VM with shared kernel | Containers share the host kernel but isolate filesystem, PID, and network |
| Dockerfile | Automated install script (like a provisioning recipe) | Declarative and layered — each instruction creates a cached, immutable layer |
| Docker image | Snapshot / VM template | Layered and content-addressable — layers are shared and deduplicated |
| `ENTRYPOINT` + `CMD` | The main process (PID 1) | Container exits when this process exits — no init system keeping it alive |
| Docker volume | External mount that survives reboots | Data persists beyond container lifecycle |
| `docker-compose` | Multi-service orchestration file | Defines an entire stack declaratively in one place |
| Multi-stage build | Build on one machine, deploy the artifact to another | Compile in a fat image, copy only the binary to a minimal runtime image |

### Example usage in teaching

> **Concept**: Dockerfile
> **What you say**: "Think of a Dockerfile like an automated install script — a recipe that starts from a base OS and runs commands to set everything up. The difference is that each line creates a separate cached layer, so if you change line 5, lines 1-4 are reused from cache. That's why you install dependencies *before* copying source code — the dependency layer only rebuilds when `requirements.txt` changes."
> **Then ask**: "Given that, which file should you `COPY` first — your source code or your dependency file? Write the two `COPY` lines and explain your ordering."

## Kubernetes

| Concept | Analogy | Key Difference |
|---|---|---|
| Pod | A single running process instance | Smallest schedulable unit — usually 1 container, can co-locate sidecars |
| Deployment | Managed process group with auto-restart | Declarative desired state — K8s reconciles to match, self-healing |
| Service (ClusterIP) | Internal DNS + load balancer | Stable virtual IP that routes to healthy pods automatically |
| Ingress | Reverse proxy with virtual host routing | Maps external HTTP(S) to internal services by hostname/path |
| ConfigMap | External config files injected at runtime | Decouples config from the application image |
| Secret | Credential store with restricted access | Base64-encoded by default (not encrypted!) — handle with care |
| Namespace | Isolated environment on shared infrastructure | Logical resource isolation (dev, staging, prod) |
| PersistentVolume | Network-attached storage | Storage that outlives pods, claimed via PersistentVolumeClaim |
| HPA | Auto-scaling triggered by metrics | Scales pods based on CPU/memory; KEDA extends to custom metrics |
| DaemonSet | Agent that runs on every node | Guarantees exactly one pod per node — log collectors, monitoring agents |
| CronJob | Scheduled task | Scheduled pod execution with retry policies and concurrency control |

### Example usage in teaching

> **Concept**: Deployment
> **What you say**: "A Deployment is like telling the system 'I always want 3 copies of this process running'. If one crashes, it's automatically replaced — similar to a process manager with auto-restart. The key addition is rolling updates: when you push a new version, it gradually replaces old pods with new ones so there's zero downtime."
> **Then ask**: "A Deployment needs a `selector` to know which Pods it manages. How do you think it matches Pods to a Deployment? Hint: it's the same concept as CSS selectors or query filters — a key-value matching system."

## CI/CD & GitOps

| Concept | Analogy | Key Difference |
|---|---|---|
| GitHub Actions workflow | Event-driven pipeline (on push, PR, schedule) | Declarative YAML, runs on managed infrastructure |
| Container registry | Package repository for container images | Stores versioned, immutable images |
| Terraform | Desired-state infrastructure manager | Plans before applying, tracks state, detects drift |
| Terraform state | Inventory tracking what Terraform manages | Compares state to reality for drift detection |
| Helm chart | Parameterized application package for Kubernetes | Templated manifests with configurable variables |

### Example usage in teaching

> **Concept**: GitHub Actions
> **What you say**: "A workflow file is an event-driven pipeline definition. You declare 'when this event happens (push, PR, schedule), run these jobs'. Each job runs on a fresh VM and executes a sequence of steps. Think of it as: trigger → environment → commands."
> **Then ask**: "The workflow file lives in a specific directory in your repo. GitHub won't find it anywhere else. What do you think that path is? Hint: it starts with a dot."

## Networking

| Concept | Analogy | Key Difference |
|---|---|---|
| VPC | Isolated network segment (VLAN) | Software-defined with full control over subnets, routing, ACLs |
| Security Group | Firewall rules (allow-list based) | Stateful, attached to instances, implicit deny |
| Load Balancer (cloud) | Managed reverse proxy | No server to maintain, auto-scales, built-in health checks |
| Service Mesh | Mutual TLS + traffic management between services | Sidecar proxies handle encryption, retries, circuit breaking transparently |

## Observability

| Concept | Analogy | Key Difference |
|---|---|---|
| Prometheus | Pull-based metrics collector | Apps expose `/metrics` endpoint, Prometheus scrapes them |
| Grafana | Query-based visualization dashboard | Dashboards-as-code via JSON provisioning |
| Structured logging (JSON) | Machine-readable log format from the start | No regex parsing needed — fields are first-class |
| Health probes | Monitoring checks (HTTP 200, port open) | Built into the orchestrator — unhealthy instances auto-restart |
