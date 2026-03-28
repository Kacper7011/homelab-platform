<div align="center">

# homelab-platform

**Personal self-hosted infrastructure — fully automated, monitored and managed as code.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Proxmox](https://img.shields.io/badge/Proxmox-VE-orange?logo=proxmox)](https://www.proxmox.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Ansible](https://img.shields.io/badge/Ansible-automation-red?logo=ansible)](https://www.ansible.com/)

![Heimdall dashboard – all services at a glance](docs/screenshots/heimdall.png)

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

![Proxmox cluster overview – 3 nodes, resource usage](docs/screenshots/proxmox.png)

---

## Architecture

Each service stack runs on a separate **virtual machine** inside the Proxmox cluster. External traffic goes through a Cloudflare Tunnel to Traefik, which acts as a reverse proxy and handles TLS termination. Metrics and logs are collected centrally by the monitoring stack.

---

## Tech Stack

Infrastructure foundations — the tools that make everything run.

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
    <td><a href="https://www.cloudflare.com/">Cloudflare + Cloudflared</a></td>
    <td>DNS, tunnel and TLS certificate management</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/tailscale" width="32" alt="Tailscale" /></td>
    <td><a href="https://tailscale.com/">Tailscale</a></td>
    <td>Zero-config VPN for secure remote access</td>
  </tr>
</table>

---

## Services

Hosted applications running on top of the infrastructure.

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/adguard" width="32" alt="AdGuard Home" /></td>
    <td><a href="https://adguard.com/en/adguard-home/overview.html">AdGuard Home</a></td>
    <td>DNS / ad blocking — network-wide privacy filter</td>
  </tr>
  <tr>
    <td>
      <img src="https://cdn.simpleicons.org/prometheus" width="32" alt="Prometheus" />
      <img src="https://raw.githubusercontent.com/grafana/loki/main/docs/sources/logo.png" width="32" alt="Loki" />
      <img src="https://cdn.simpleicons.org/grafana" width="32" alt="Grafana" />
    </td>
    <td><a href="https://prometheus.io/">Prometheus</a> + <a href="https://grafana.com/oss/loki/">Loki</a> + <a href="https://grafana.com/">Grafana</a></td>
    <td>Monitoring & observability — metrics, logs and dashboards</td>
  </tr>
  <tr>
    <td>
      <img src="https://forgejo.org/favicon.ico" width="32" alt="Forgejo" />
      <img src="https://forgejo.org/favicon.ico" width="32" alt="Forgejo Runner" />
    </td>
    <td><a href="https://forgejo.org/">Forgejo</a> + <a href="https://code.forgejo.org/forgejo/runner">Forgejo Runner</a></td>
    <td>Git & CI/CD — self-hosted repositories and pipelines</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/seafile" width="32" alt="Seafile" /></td>
    <td><a href="https://www.seafile.com/">Seafile</a></td>
    <td>File storage — self-hosted alternative to Google Drive / Dropbox</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/syncthing" width="32" alt="Syncthing" /></td>
    <td><a href="https://syncthing.net/">Syncthing</a></td>
    <td>File sync — peer-to-peer synchronization between devices</td>
  </tr>
  <tr>
    <td><img src="https://cdn.simpleicons.org/bitwarden" width="32" alt="Vaultwarden" /></td>
    <td><a href="https://github.com/dani-garcia/vaultwarden">Vaultwarden</a></td>
    <td>Password manager — self-hosted, Bitwarden compatible</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/navidrome/navidrome/master/resources/logo-192x192.png" width="32" alt="Navidrome" /></td>
    <td><a href="https://www.navidrome.org/">Navidrome</a></td>
    <td>Music streaming — self-hosted, Subsonic-compatible</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/linuxserver/Heimdall/master/public/android-icon-192x192.png" width="32" alt="Heimdall" /></td>
    <td><a href="https://heimdall.site/">Heimdall</a></td>
    <td>Dashboard — start page with links to all services</td>
  </tr>
</table>

![Grafana dashboard – cluster metrics and VM overview](docs/screenshots/grafana.png)


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
