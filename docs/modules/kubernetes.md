# Kubernetes

## Overview

Kubernetes runs on a dedicated virtual machine inside the Proxmox cluster. Its sole role in this homelab is to expose selected services to the internet via the Cloudflare Tunnel — all other services run as Docker Compose stacks on separate VMs.

Traffic flow: Cloudflare → Cloudflared (running in Kubernetes) → Traefik (ingress controller) → service.

Manifests are under `kubernetes/manifests/`. Third-party components are managed with Helm; chart values are under `kubernetes/releases/`.

---

## Namespace Inventory

| Namespace | Contents |
|-----------|----------|
| `cloudflared` | Cloudflare Tunnel agent (2 replicas) |
| `navidrome` | Navidrome music streaming service |
| `vault` | RBAC resources for Vault Agent Injector |

---

## Manifests

### cloudflared

**Directory:** `kubernetes/manifests/cloudflared/`

Runs the `cloudflare/cloudflared` container with two replicas for availability. Connects to the Cloudflare Zero Trust Tunnel and forwards incoming traffic to Traefik.

The tunnel token is read from a Kubernetes Secret:

```yaml
env:
  - name: TUNNEL_TOKEN
    valueFrom:
      secretKeyRef:
        name: cloudflared-tunnel-token
        key: TUNNEL_TOKEN
```

The Secret is not stored in the repository — create it manually before applying:

```bash
kubectl create secret generic cloudflared-tunnel-token \
  --from-literal=TUNNEL_TOKEN=<token> \
  -n cloudflared
```

| Resource | Kind | Notes |
|----------|------|-------|
| `namespace.yaml` | Namespace | `cloudflared` |
| `serviceaccount.yaml` | ServiceAccount | `cloudflared-sa` |
| `deployment.yaml` | Deployment | 2 replicas, 128Mi/200m limits |

```bash
kubectl apply -f kubernetes/manifests/cloudflared/
```

---

### navidrome

**Directory:** `kubernetes/manifests/navidrome/`

Music streaming service exposed through the Cloudflare Tunnel. Uses the `Recreate` deployment strategy to avoid two pods mounting the same PVC simultaneously.

| Resource | Kind | Notes |
|----------|------|-------|
| `namespace.yaml` | Namespace | `navidrome` |
| `configmap.yaml` | ConfigMap | `ND_SCANINTERVAL=1m`, `ND_ENABLELEGACYAUTH=true` |
| `pvc.yaml` | PersistentVolumeClaim | 5 Gi, `local-path` storage class |
| `deployment.yaml` | Deployment | 1 replica, mounts PVC + host path `/srv/music/library` |
| `service.yaml` | Service | ClusterIP, port 4533 |
| `ingress.yaml` | Ingress | Traefik, routes `music.kacper-nxn.pl → navidrome-svc:4533` |

```bash
kubectl apply -f kubernetes/manifests/navidrome/
```

---

### vault

**Directory:** `kubernetes/manifests/vault/`

Contains only RBAC resources needed by the Vault Agent Injector (deployed via Helm) to authenticate Kubernetes service accounts against the external Vault instance.

| Resource | Kind | Notes |
|----------|------|-------|
| `namespace.yaml` | Namespace | `vault` |
| `token.yaml` | Secret | `kubernetes.io/service-account-token` for `vault-auth` SA |
| `rbac.yaml` | ClusterRoleBinding | Binds `vault-auth` SA to `system:auth-delegator` |

```bash
kubectl apply -f kubernetes/manifests/vault/
```

---

## Helm Releases

### vault

**Directory:** `kubernetes/releases/vault/`  
**Chart:** `hashicorp/vault`

Deploys only the Vault Agent Injector — the Vault server itself runs as a Docker container on `prox-vault` (10.10.10.216), so `global.enabled` is set to `false`.

```yaml
global:
  enabled: false
  externalVaultAddr: "http://10.10.10.216:8200"

injector:
  enabled: true
  externalVaultAddr: "http://10.10.10.216:8200"
```

Install or upgrade:

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
  --namespace vault \
  -f kubernetes/releases/vault/values.yaml
```

---

## Apply Order

1. `kubernetes/manifests/vault/` — RBAC must exist before the Helm chart creates the injector
2. Helm: `hashicorp/vault` — deploys the Vault Agent Injector
3. `kubernetes/manifests/cloudflared/` — requires the tunnel token Secret to exist first
4. `kubernetes/manifests/navidrome/` — no external dependencies
