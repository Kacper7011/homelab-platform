# Architecture

## Infrastructure Topology

The platform runs on a three-node Proxmox cluster. Virtual machines and LXC containers are created on that cluster, and Docker services run inside those VMs and containers.

```
┌─────────────────────────────────────────────┐
│           Proxmox Cluster (3 nodes)         │
│   pve01 · pve02 · pve03                     │
│                                             │
│  ┌──────────────┐  ┌──────────────────────┐ │
│  │     VMs      │  │   LXC Containers     │ │
│  │ prox-services│  │ prox-gateway         │ │
│  │ prox-monitor │  │ prox-adguard-master  │ │
│  │ prox-cicd    │  │ prox-adguard-backup  │ │
│  │ prox-vault   │  │ prox-tailscale       │ │
│  │ prox-mgmt    │  └──────────────────────┘ │
│  └──────────────┘                           │
└─────────────────────────────────────────────┘
```

## Host Inventory

| Host | Type | IP | Role |
|------|------|----|------|
| pve01 | Proxmox node | 10.10.10.31 | Hypervisor |
| pve02 | Proxmox node | 10.10.10.32 | Hypervisor |
| pve03 | Proxmox node | 10.10.10.33 | Hypervisor |
| prox-services | VM | 10.10.10.115 | Runs navidrome, seafile, forgejo, rustfs... |
| prox-monitoring | VM | 10.10.10.107 | Runs Prometheus, Loki, Grafana |
| prox-vault | VM | 10.10.10.216 | Runs HashiCorp Vault |
| prox-management | VM | 10.10.10.121 | Management tasks |
| prox-gateway | LXC | 10.10.10.224 | Runs Traefik, Cloudflared, AdGuard Sync |
| prox-adguard-master | LXC | 10.10.10.50 | Primary DNS (AdGuard Home) |
| prox-adguard-backup | LXC | 10.10.10.55 | Backup DNS (AdGuard Home) |
| prox-tailscale | LXC | 10.10.10.70 | VPN access node |

## Module Dependency Diagram

The modules depend on each other in a specific order. You must set up lower layers before the ones above them will work.

```
┌──────────────────────────────────────────────────┐
│                Docker Services                   │
│  (read secrets from ~/.secrets/<service>/.env)   │
└─────────────────────┬────────────────────────────┘
                      │ secrets deployed by
┌─────────────────────▼────────────────────────────┐
│                    Ansible                        │
│  (reads secrets from Vault, deploys .env files)  │
└─────────────────────┬────────────────────────────┘
                      │ reads from
┌─────────────────────▼────────────────────────────┐
│              HashiCorp Vault                      │
│  (stores all service secrets and credentials)    │
└─────────────────────┬────────────────────────────┘
                      │ configured by
┌─────────────────────▼────────────────────────────┐
│             Terraform (vault module)              │
│  (creates AppRoles, policies, KV secrets)        │
└─────────────────────┬────────────────────────────┘
                      │ state stored in
┌─────────────────────▼────────────────────────────┐
│        RustFS  (S3-compatible storage)            │
│  (stores Terraform state for all three modules)  │
└──────────────────────────────────────────────────┘
```

**Cloudflare** (the third Terraform module) is independent of Vault. It creates DNS records and a Zero Trust Tunnel and can be applied after the gateway service is running.

**Restic backups** depend on both Vault (for credentials) and RustFS (as the backup destination).

## External Traffic Flow

All public traffic goes through Cloudflare before it reaches any service:

```
User → Cloudflare DNS → Cloudflare Tunnel → Cloudflared container
                                                     │
                                                     ▼
                                              Traefik (proxy)
                                                     │
                                     ┌───────────────┼───────────────┐
                                     ▼               ▼               ▼
                               homepage          seafile          forgejo
                               grafana          vaultwarden        ...
```

Traefik discovers services automatically using Docker labels. Each service that should be publicly accessible has a `traefik.enable=true` label and a routing rule in its compose file or in the static config at `docker/gateway/traefik/traefik.yaml`.