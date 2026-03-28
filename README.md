<div align="center">

# homelab-platform

**Personal self-hosted infrastructure — fully automated, monitored and managed as code.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Proxmox](https://img.shields.io/badge/Proxmox-VE-orange?logo=proxmox)](https://www.proxmox.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Ansible](https://img.shields.io/badge/Ansible-automation-red?logo=ansible)](https://www.ansible.com/)

![Overview placeholder – screenshot of Heimdall or Grafana dashboard](docs/screenshots/overview.png)

</div>

---

## About

This homelab was built to learn new technologies and create a personal infrastructure that is independent from external cloud services. The whole environment is described as code (IaC), so it can be rebuilt from scratch at any time.

**Main goals:**

- Learn modern DevOps and Platform Engineering practices
- Infrastructure as code — reproducible, versioned and automated
- Single source of truth for the entire environment

---

## Hardware

| Node   | Model                         | CPU            | RAM   | Storage |
|--------|-------------------------------|----------------|-------|---------|
| pve01  | Lenovo ThinkCentre M910Q Tiny | Intel i5-7500T | 16 GB | 256 GB  |
| pve02  | Lenovo ThinkCentre M910Q Tiny | Intel i5-7500T | 16 GB | 256 GB  |
| pve03  | Lenovo ThinkCentre M910Q Tiny | Intel i7-6700T | 16 GB | 240 GB  |

All three nodes form a **Proxmox VE** cluster, which runs virtual machines that host the individual service stacks.

---

## Architecture

![Architecture placeholder – network / VM layout diagram](docs/screenshots/architecture.png)

Each service stack runs on a separate **virtual machine** inside the Proxmox cluster. External traffic goes through a Cloudflare Tunnel to Traefik, which acts as a reverse proxy and handles TLS termination. Metrics and logs are collected centrally by the monitoring stack.

---

## Services

### Gateway

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/traefikproxy" width="32" alt="Traefik" /></td>
    <td><a href="https://traefik.io/">Traefik</a></td>
    <td>Reverse proxy — routing, TLS, auto-discovery via Docker labels</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/cloudflare" width="32" alt="Cloudflare" /></td>
    <td><a href="https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/">Cloudflared</a></td>
    <td>Cloudflare Tunnel — secure external access without opening ports</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/tailscale" width="32" alt="Tailscale" /></td>
    <td><a href="https://tailscale.com/">Tailscale</a></td>
    <td>Zero-config VPN — secure access to the homelab from anywhere</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/adguard" width="32" alt="AdGuard Home" /></td>
    <td><a href="https://adguard.com/en/adguard-home/overview.html">AdGuard Home</a></td>
    <td>Network-wide DNS ad blocker and privacy filter</td>
  </tr>
</table>

### Monitoring

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/prometheus" width="32" alt="Prometheus" /></td>
    <td><a href="https://prometheus.io/">Prometheus</a></td>
    <td>Metrics collection and storage (node exporter, cAdvisor, pve-exporter)</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/grafana/loki/main/docs/sources/logo.png" width="32" alt="Loki" /></td>
    <td><a href="https://grafana.com/oss/loki/">Loki</a></td>
    <td>Log aggregation from machines and containers</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/grafana" width="32" alt="Grafana" /></td>
    <td><a href="https://grafana.com/">Grafana</a></td>
    <td>Dashboards and visualization for metrics and logs</td>
  </tr>
</table>

![Grafana placeholder – screenshot of metrics dashboard](docs/screenshots/grafana.png)

### CI/CD

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://forgejo.org/favicon.ico" width="32" alt="Forgejo" /></td>
    <td><a href="https://forgejo.org/">Forgejo</a></td>
    <td>Self-hosted Git — repositories and code review</td>
  </tr>
  <tr>
    <td><img src="https://forgejo.org/favicon.ico" width="32" alt="Forgejo Runner" /></td>
    <td><a href="https://code.forgejo.org/forgejo/runner">Forgejo Runner</a></td>
    <td>CI/CD pipeline runner (Docker-in-Docker)</td>
  </tr>
</table>

### Storage & Sync

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/seafile" width="32" alt="Seafile" /></td>
    <td><a href="https://www.seafile.com/">Seafile</a></td>
    <td>Self-hosted file storage — alternative to Google Drive / Dropbox</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/syncthing" width="32" alt="Syncthing" /></td>
    <td><a href="https://syncthing.net/">Syncthing</a></td>
    <td>Peer-to-peer file sync between devices</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/bitwarden" width="32" alt="Vaultwarden" /></td>
    <td><a href="https://github.com/dani-garcia/vaultwarden">Vaultwarden</a></td>
    <td>Self-hosted password manager (Bitwarden compatible)</td>
  </tr>
</table>

### Media

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/navidrome/navidrome/master/resources/logo-192x192.png" width="32" alt="Navidrome" /></td>
    <td><a href="https://www.navidrome.org/">Navidrome</a></td>
    <td>Self-hosted music server, Subsonic-compatible</td>
  </tr>
</table>

### Dashboard

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/linuxserver/Heimdall/master/public/android-icon-192x192.png" width="32" alt="Heimdall" /></td>
    <td><a href="https://heimdall.site/">Heimdall</a></td>
    <td>Start page with links to all services</td>
  </tr>
</table>

![Heimdall placeholder – screenshot of the dashboard](docs/screenshots/heimdall.png)

---

## Tech Stack

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/proxmox" width="32" alt="Proxmox" /></td>
    <td><a href="https://www.proxmox.com/">Proxmox VE</a></td>
    <td>Hypervisor — runs the entire cluster of virtual machines</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/docker" width="32" alt="Docker" /></td>
    <td><a href="https://docs.docker.com/compose/">Docker + Docker Compose</a></td>
    <td>Container runtime and service orchestration</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/ansible" width="32" alt="Ansible" /></td>
    <td><a href="https://www.ansible.com/">Ansible</a></td>
    <td>Automates VM provisioning and configuration</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/traefikproxy" width="32" alt="Traefik" /></td>
    <td><a href="https://traefik.io/">Traefik</a></td>
    <td>Reverse proxy with automatic TLS and Docker integration</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/cloudflare" width="32" alt="Cloudflare" /></td>
    <td><a href="https://www.cloudflare.com/">Cloudflare</a></td>
    <td>DNS, tunnel and TLS certificate management</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/tailscale" width="32" alt="Tailscale" /></td>
    <td><a href="https://tailscale.com/">Tailscale</a></td>
    <td>Zero-config VPN for secure remote access</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/adguard" width="32" alt="AdGuard Home" /></td>
    <td><a href="https://adguard.com/en/adguard-home/overview.html">AdGuard Home</a></td>
    <td>Network-wide DNS ad blocking</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/prometheus" width="32" alt="Prometheus" /></td>
    <td><a href="https://prometheus.io/">Prometheus</a></td>
    <td>Metrics collection and alerting</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/grafana/loki/main/docs/sources/logo.png" width="32" alt="Loki" /></td>
    <td><a href="https://grafana.com/oss/loki/">Loki</a></td>
    <td>Log aggregation and storage</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/grafana" width="32" alt="Grafana" /></td>
    <td><a href="https://grafana.com/">Grafana</a></td>
    <td>Metrics and logs visualization</td>
  </tr>
  <tr>
    <td><img src="https://forgejo.org/favicon.ico" width="32" alt="Forgejo" /></td>
    <td><a href="https://forgejo.org/">Forgejo</a></td>
    <td>Self-hosted Git platform</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/seafile" width="32" alt="Seafile" /></td>
    <td><a href="https://www.seafile.com/">Seafile</a></td>
    <td>Self-hosted file sync and storage</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/syncthing" width="32" alt="Syncthing" /></td>
    <td><a href="https://syncthing.net/">Syncthing</a></td>
    <td>Peer-to-peer file synchronization</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/bitwarden" width="32" alt="Vaultwarden" /></td>
    <td><a href="https://github.com/dani-garcia/vaultwarden">Vaultwarden</a></td>
    <td>Self-hosted password manager</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/navidrome/navidrome/master/resources/logo-192x192.png" width="32" alt="Navidrome" /></td>
    <td><a href="https://www.navidrome.org/">Navidrome</a></td>
    <td>Self-hosted music streaming server</td>
  </tr>
</table>

---

## Repository Structure

```
homelab-platform/
├── ansible/                  # Ansible playbooks and roles
│   ├── inventories/          # Host inventory (example included)
│   ├── playbooks/            # Node exporter, cAdvisor, Promtail setup, etc.
│   └── roles/                # Roles: bootstrap, docker, ...
├── cicd/                     # Forgejo + Forgejo Runner
├── docker/
│   ├── gateway/              # Traefik + Cloudflared
│   ├── heimdall/             # Dashboard
│   ├── monitoring/           # Prometheus + Loki + Grafana
│   ├── music-stack/          # Navidrome + Syncthing
│   ├── seafile/              # Seafile + MariaDB + Memcached
│   └── vaultwarden/          # Vaultwarden
└── docs/
    └── screenshots/          # Screenshots used in README
```

---

## Getting Started

Each stack is started independently with `docker compose up -d` from its directory.

**Prerequisites:**
- Docker + Docker Compose
- A `.env` file with the required variables (template: `.env.example` in each directory)

**Example:**

```bash
cd docker/monitoring
cp .env.example .env
# fill in the variables in .env
docker compose up -d
```

VM configuration and exporter setup on the hosts is handled by Ansible:

```bash
cd ansible
ansible-playbook -i inventories/hosts.yml playbooks/node-exporter-setup.yml
```

---

## License

[MIT](LICENSE) — feel free to use anything here as inspiration for your own homelab.
