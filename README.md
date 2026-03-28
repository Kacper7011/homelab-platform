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

| Service      | Description                                                        |
|--------------|--------------------------------------------------------------------|
| [Traefik](https://traefik.io/) | Reverse proxy — routing, TLS, auto-discovery via Docker labels |
| [Cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) | Cloudflare Tunnel — secure external access without opening ports |

### Monitoring

| Service         | Description                                                   |
|-----------------|---------------------------------------------------------------|
| [Prometheus](https://prometheus.io/) | Metrics collection and storage (node exporter, cAdvisor, pve-exporter) |
| [Loki](https://grafana.com/oss/loki/) | Log aggregation from machines and containers               |
| [Grafana](https://grafana.com/) | Dashboards and visualization for metrics and logs          |

### CI/CD

| Service            | Description                                              |
|--------------------|----------------------------------------------------------|
| [Forgejo](https://forgejo.org/) | Self-hosted Git — repositories and code review         |
| [Forgejo Runner](https://code.forgejo.org/forgejo/runner) | CI/CD pipeline runner (Docker-in-Docker)            |

### Storage & Sync

| Service        | Description                                                       |
|----------------|-------------------------------------------------------------------|
| [Seafile](https://www.seafile.com/) | Self-hosted file storage — alternative to Google Drive / Dropbox |
| [Syncthing](https://syncthing.net/) | Peer-to-peer file sync between devices                        |
| [Vaultwarden](https://github.com/dani-garcia/vaultwarden) | Self-hosted password manager (Bitwarden compatible)        |

### Media

| Service        | Description                                                  |
|----------------|--------------------------------------------------------------|
| [Navidrome](https://www.navidrome.org/) | Self-hosted music server, Subsonic-compatible           |

### Dashboard

| Service     | Description                                      |
|-------------|--------------------------------------------------|
| [Heimdall](https://heimdall.site/) | Start page with links to all services         |

---

## Tech Stack

| Category             | Technology                    |
|----------------------|-------------------------------|
| Hypervisor           | Proxmox VE                    |
| Containers           | Docker + Docker Compose       |
| Automation           | Ansible                       |
| Reverse proxy / TLS  | Traefik + Cloudflare          |
| Monitoring           | Prometheus + Loki + Grafana   |
| CI/CD                | Forgejo + Forgejo Runner      |
| Storage              | Seafile + Syncthing           |

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

[MIT](LICENSE)
