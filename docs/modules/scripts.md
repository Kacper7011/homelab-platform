# Scripts & Utilities

## Overview

The `scripts/` directory contains shell scripts for managing credentials. These are helper tools — they do not deploy anything on their own.

The `ansible/templates/` directory contains Jinja2 templates used by Ansible playbooks to generate files on target hosts.

---

## scripts/ansible/ansible_export_vault_credentials.sh

**Purpose:** Exports Vault and AppRole credentials as environment variables for the current shell session. Required before running any Ansible playbook.

**How to use — must be sourced, not executed:**

```bash
. scripts/ansible/ansible_export_vault_credentials.sh
```

**Variables it sets:**

| Variable | Value |
|----------|-------|
| `VAULT_ADDR` | `http://10.10.10.216:8200` |
| `ANSIBLE_HASHI_VAULT_AUTH_METHOD` | `approle` |
| `ANSIBLE_HASHI_VAULT_ROLE_ID` | contents of `~/.vault/ansible/role_id` |
| `ANSIBLE_HASHI_VAULT_SECRET_ID` | contents of `~/.vault/ansible/secret_id` |

Both credential files must exist before sourcing this script. See [secrets.md](../secrets.md) for how to create them.

---

## scripts/ansible/ansible_refresh_vault_credentials.sh

**Purpose:** Generates a new Vault AppRole secret ID and overwrites `~/.vault/ansible/secret_id`. Run this before the current secret ID expires (TTL is 10 days).

**How to use:**

```bash
bash scripts/ansible/ansible_refresh_vault_credentials.sh
```

This script is intended to run automatically via cron. To set it up:

```bash
crontab -e
```

Add this line:

```
0 6 * * 0  /bin/bash ~/scripts/ansible_refresh_vault_credentials.sh
```

This runs every Sunday at 06:00.

**Requirements:**
- `vault` CLI must be installed and on `$PATH`
- `jq` must be installed
- `~/.vault/root_token` must contain the Vault root token
- `~/.vault/ansible/` directory must exist

**What it does:**
1. Reads the root token from `~/.vault/root_token`
2. Calls `vault write -f auth/approle/role/ansible/secret-id` to generate a new secret ID
3. Writes the new secret ID to `~/.vault/ansible/secret_id` with `chmod 600`
4. Appends a log entry to `~/.vault/ansible/ansible_refresh.log`

---

## scripts/rustfs/rustfs_export_credentials.sh

**Purpose:** Exports RustFS S3 credentials as environment variables. Required before running `terraform init` or `terraform apply` in any Terraform module (because all modules use RustFS as the state backend).

**How to use — must be sourced, not executed:**

```bash
. scripts/rustfs/rustfs_export_credentials.sh
```

**Variables it sets:**

| Variable | Source file |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | `~/.vault/rustfs/access_key` |
| `AWS_SECRET_ACCESS_KEY` | `~/.vault/rustfs/secret_key` |

Both files must exist. Write the access key and secret key from your RustFS admin into them after you first set up RustFS.

---

## Ansible Templates

These Jinja2 templates are used by Ansible playbooks to render configuration files and scripts on target hosts. They are located in `ansible/templates/`.

### env.j2

Used by `deploy-env-files.yml` to generate `.env` files for Docker services.

Iterates over the `env_vars` dict (fetched from Vault) and writes each key-value pair on its own line:

```
KEY=value
ANOTHER_KEY=another_value
```

### restic-backup.sh.j2

Used by `restic-backup.yml` to generate the backup script on each target host.

The rendered script:
- Exports S3 and restic credentials (filled in from Vault at render time)
- Sets the restic repository path to `s3://<endpoint>/<bucket>/<hostname>`
- Initializes the repository if it does not exist yet
- Backs up `/var/lib/docker/volumes` on every host
- Has per-hostname sections where you can add extra paths
- Applies a retention policy: keep last 5, 7 daily, 4 weekly, 2 monthly
- Logs all activity to `/home/kacper/logs/restic-backup.log`

To add backup paths for a new host, edit the `case` block in the template and add a new section:

```bash
prox-newhost)
  EXTRA_PATHS=(
    /opt/your-data
  )
  ;;
```

### promtail-prox.yml.j2 / promtail-vm.yml.j2

Used by `promtail-setup-prox.yml` and `promtail-setup-vm.yml` to generate the Promtail configuration file on each host.

Promtail is the log shipping agent for Loki. The template sets the Loki endpoint and defines which log files to watch.

### node_exporter.service.j2

Used by `node-exporter-setup.yml` to generate the systemd unit file for the Prometheus node exporter.

Enables these collectors by default: `systemd`, `processes`, `filesystem`. On non-LXC hosts (real VMs), it also enables the `zfs` collector.

### cadvisor-compose.yaml.j2

Used by `cadvisor-setup.yml` to deploy cAdvisor as a Docker Compose stack on each host.

cAdvisor collects container resource usage metrics (CPU, memory, network) and exposes them for Prometheus to scrape.
