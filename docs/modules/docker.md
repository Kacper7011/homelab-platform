# Docker Services

## Overview

All services run as Docker Compose stacks. Each service has its own directory under `docker/` with a `docker-compose.yaml` file and any additional config files it needs.

Services are not deployed from this machine — they are started directly on the target host by running `docker compose up -d` in the service directory.

## Service Inventory

| Service | Host | IP | Exposed Port(s) | Description |
|---------|------|----|-----------------|-------------|
| monitoring | prox-monitoring | 10.10.10.107 | 9090, 3100, 3000 | Prometheus, Loki, Grafana |
| gateway | prox-gateway | 10.10.10.224 | 8080, 8082 | Traefik reverse proxy |
| cloudflared | prox-gateway | 10.10.10.224 | 2000 (metrics) | Cloudflare Tunnel agent |
| vault | prox-vault | 10.10.10.216 | 8200 | HashiCorp Vault |
| forgejo | prox-services | 10.10.10.115 | 3030, 222 | Git server + CI runner |
| seafile | prox-services | 10.10.10.115 | 9000 | File storage |
| rustfs | prox-services | 10.10.10.115 | 9020, 9001 | S3-compatible object storage |
| homepage | prox-services | 10.10.10.115 | 3000 | Service dashboard |
| vaultwarden | prox-services | 10.10.10.115 | 8000 | Password manager |
| navidrome | prox-services | 10.10.10.115 | 4533 | Music streaming |
| syncthing | prox-services | 10.10.10.115 | 8384, 22000, 21027 | File sync |
| heimdall | prox-gateway | 10.10.10.224 | 8080 | Start page |
| adguard-sync | prox-gateway | 10.10.10.224 | — | DNS config sync |
| homelab-hub | prox-services | 10.10.10.115 | 8020 | Admin dashboard |

## Secret Injection

Most services read their credentials from a `.env` file that Ansible deploys onto the host:

```yaml
env_file:
  - ~/.secrets/<service>/.env
```

Before starting any service that uses an `env_file`, run the `deploy-env-files.yml` Ansible playbook. If the file is missing, Docker will refuse to start the container.

See [secrets.md](../secrets.md) and [modules/ansible.md](ansible.md) for details.

## Docker Networks

| Network | Driver | Used by |
|---------|--------|---------|
| `proxy` | bridge | Traefik, Cloudflared |
| `monitoring` | bridge | Prometheus, Loki, Grafana |
| `forgejo` | bridge | Forgejo, Forgejo Runner |
| `vault-net` | bridge | Vault |

Other services (seafile, homepage, vaultwarden, etc.) use the default bridge network created by Docker Compose.

---

## Services

### monitoring

**Host:** prox-monitoring (10.10.10.107)  
**Directory:** `docker/monitoring/`

Contains three containers in a single compose file:

- **Prometheus** — collects metrics from all exporters. Retains data for 30 days. Config at `docker/monitoring/prometheus/prometheus.yml`. Data stored at `/mnt/monitoring/prometheus_data`.
- **Loki** — receives logs from Promtail agents running on all hosts. Config at `docker/monitoring/loki/loki.yml`. Data stored at `/mnt/monitoring/loki_data`.
- **Grafana** — visualization dashboard. Reads credentials from `~/.secrets/grafana/.env`. Provisioning config at `docker/monitoring/grafana/provisioning/`.

```bash
cd docker/monitoring
docker compose up -d
```

---

### gateway

**Host:** prox-gateway (10.10.10.224)  
**Directory:** `docker/gateway/`

Contains two containers:

- **Traefik** — reverse proxy. Reads its static config from `docker/gateway/traefik/traefik.yaml` and dynamic config from `docker/gateway/traefik/config/`. Discovers services via the Docker socket.
- **Cloudflared** — connects to the Cloudflare Zero Trust Tunnel. Reads the tunnel token from `~/.secrets/cloudflared/.env`.

Both containers share the `proxy` Docker network.

```bash
cd docker/gateway
docker compose up -d
```

---

### vault

**Host:** prox-vault (10.10.10.216)  
**Directory:** `docker/vault/`

Runs HashiCorp Vault 1.17. Configuration files are at `docker/vault/config/`. Data is stored in the `vault_data` Docker volume.

Requires the `IPC_LOCK` capability to prevent secrets from being swapped to disk.

After the first start, Vault must be manually initialized and unsealed.

```bash
cd docker/vault
docker compose up -d
```

---

### forgejo

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/forgejo/`

Contains two containers:

- **Forgejo** — self-hosted Git server, accessible on port 3030 (HTTP) and 222 (SSH)
- **Forgejo Runner** — CI/CD agent. Reads its registration token from `~/.secrets/forgejo/.env` and auto-registers itself on first start. Mounts the Docker socket to run jobs as containers.

Both containers share the `forgejo` network.

```bash
cd docker/forgejo
docker compose up -d
```

---

### seafile

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/seafile/`

Contains three containers:

- **MariaDB** — database backend. Reads credentials from `~/.secrets/seafile/.env`. Data stored in the `seafile_mysql` volume.
- **Memcached** — in-memory cache. No configuration needed.
- **Seafile** — the main file storage service. Reads credentials from `~/.secrets/seafile/.env`. Data stored at `/srv/seafile/data`.

Seafile depends on both MariaDB and Memcached being healthy before it starts.

```bash
cd docker/seafile
docker compose up -d
```

---

### vaultwarden

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/vaultwarden/`

Bitwarden-compatible password manager. New user registration is disabled. Data is stored in the `vaultwarden_data` volume.

Does not use an `env_file` — all configuration is set via `environment` in the compose file.

```bash
cd docker/vaultwarden
docker compose up -d
```

---

### navidrome

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/navidrome/`

Music streaming server. Mounts the music library from `/srv/music/library` (read-only). Metadata is stored in the `navidrome_data` volume. Scans for new files every minute.

```bash
cd docker/navidrome
docker compose up -d
```

---

### syncthing

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/syncthing/`

P2P file synchronization. Mounts `/srv/music/library` to keep the music library in sync with other devices. The web UI is on port 8384. Sync ports are 22000 (TCP/UDP) and 21027 (UDP).

```bash
cd docker/syncthing
docker compose up -d
```

---

### homepage

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/homepage/`

Service dashboard. Configuration files are at `docker/homepage/config/`. Custom images are served from `/home/kacper/images`. Mounts the Docker socket to show container status. Reads credentials from `~/.secrets/homepage/.env`.

```bash
cd docker/homepage
docker compose up -d
```

---

### heimdall

**Host:** prox-gateway (10.10.10.224)  
**Directory:** `docker/heimdall/`

Simple browser start page. Configuration and bookmarks stored at `/srv/heimdall/config`.

```bash
cd docker/heimdall
docker compose up -d
```

---

### rustfs

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/rustfs/`

S3-compatible object storage. Reads credentials from `~/.secrets/rustfs/.env`. Data stored at `/mnt/rustfs-data`. Runs as a non-root user (UID 10001). The S3 API is on port 9020 and the web console on port 9001.

```bash
cd docker/rustfs
docker compose up -d
```

---

### adguard-sync

**Host:** prox-gateway (10.10.10.224)  
**Directory:** `docker/adguard-sync/`

Syncs AdGuard Home configuration from the master instance (10.10.10.50) to the backup instance (10.10.10.55) every 5 minutes. Reads credentials from `~/.secrets/adguard_home_sync/.env`.

```bash
cd docker/adguard-sync
docker compose up -d
```

---

### homelab-hub

**Host:** prox-services (10.10.10.115)  
**Directory:** `docker/homelab-hub/`

Lightweight admin dashboard. Data stored in the `homelab_hub_data` volume. Accessible on port 8020.

```bash
cd docker/homelab-hub
docker compose up -d
```

---

## Running Services

All services follow the same pattern. On the target host:

```bash
cd docker/<service-name>
docker compose up -d
```

To check logs:

```bash
docker compose logs -f
```

To restart a service after updating its `.env` file:

```bash
docker compose down && docker compose up -d
```
