# Variables Reference

This page lists all variables, credentials, and environment settings used across the project, grouped by where they come from and where they are used.

---

## Shell Exports

These variables are not stored in config files — they must be exported in the current shell session before running Ansible or Terraform. Use the provided scripts to set them.

### Vault / Ansible credentials

Source: `scripts/ansible/ansible_export_vault_credentials.sh`

```bash
. scripts/ansible/ansible_export_vault_credentials.sh
```

| Variable | Description | Required for |
|----------|-------------|--------------|
| `VAULT_ADDR` | Vault server URL (`http://10.10.10.216:8200`) | Ansible, Vault CLI |
| `ANSIBLE_HASHI_VAULT_AUTH_METHOD` | Auth method (`approle`) | Ansible |
| `ANSIBLE_HASHI_VAULT_ROLE_ID` | AppRole role ID (from `~/.vault/ansible/role_id`) | Ansible |
| `ANSIBLE_HASHI_VAULT_SECRET_ID` | AppRole secret ID (from `~/.vault/ansible/secret_id`) | Ansible |

### RustFS / S3 credentials

Source: `scripts/rustfs/rustfs_export_credentials.sh`

```bash
. scripts/rustfs/rustfs_export_credentials.sh
```

| Variable | Description | Required for |
|----------|-------------|--------------|
| `AWS_ACCESS_KEY_ID` | RustFS access key (from `~/.vault/rustfs/access_key`) | Terraform (all modules) |
| `AWS_SECRET_ACCESS_KEY` | RustFS secret key (from `~/.vault/rustfs/secret_key`) | Terraform (all modules) |

---

## Terraform Variables

Each Terraform module reads its variables from a `terraform.tfvars` file in that module's directory. These files are **not committed to the repository** — create them manually.

### terraform/rustfs/

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `rustfs_access_key` | Admin access key for RustFS | No |
| `rustfs_secret_key` | Admin secret key for RustFS | Yes |
| `rustfs_address` | Full URL of RustFS (e.g. `http://10.10.10.115:9020`) | No |
| `rustfs_host` | Host:port without scheme (e.g. `10.10.10.115:9020`) | No |
| `restic_secret` | Secret key to assign to the restic IAM user | Yes |

### terraform/vault/

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `vault_address` | Vault server URL | No |
| `root_token` | Vault root token | Yes |
| `sys_user_username` | Username for the Ansible system user | No |
| `sys_user_password` | Password for the Ansible system user | Yes |
| `restic_access_key` | S3 access key stored in Vault for restic | No |
| `restic_secret_access_key` | S3 secret key stored in Vault for restic | Yes |
| `restic_repo_password` | Encryption password for the restic repository | Yes |
| `ansible_ssh_private_key` | Private SSH key for Ansible | Yes |
| `ansible_ssh_public_key` | Public SSH key for Ansible | No |
| `homepage_env` | `map(string)` — env vars for the homepage service | Yes |
| `seafile_env` | `map(string)` — env vars for seafile + MariaDB | Yes |
| `forgejo_env` | `map(string)` — env vars for the Forgejo runner | Yes |
| `cloudflared_env` | `map(string)` — must include `TUNNEL_TOKEN` | Yes |
| `adguard_home_sync_env` | `map(string)` — env vars for AdGuard Sync | Yes |
| `grafana_env` | `map(string)` — env vars for Grafana | Yes |
| `rustfs_env` | `map(string)` — env vars for RustFS | Yes |

### terraform/cloudflare/

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `cloudflare_api_token` | Cloudflare API token | Yes |
| `cloudflare_zone_id` | Zone ID of your domain | No |
| `cloudflare_account_id` | Cloudflare account ID | No |
| `cloudflare_tunnel_secret` | Secret used to create the Zero Trust Tunnel | Yes |
| `domain_name` | Your public domain name (e.g. `example.com`) | No |

---

## Ansible Variables

### Vault Connection (group_vars/all/vault.yml)

These are set in `ansible/group_vars/all/vault.yml` and apply to all hosts:

| Variable | Value |
|----------|-------|
| `ansible_hashi_vault_url` | `http://10.10.10.216:8200` |
| `ansible_hashi_vault_auth_method` | `approle` |

The role ID and secret ID are not stored in the inventory — they come from the shell environment (see [Shell Exports](#shell-exports) above).

### Inventory Variables (hosts.yml)

| Variable | Where set | Description |
|----------|-----------|-------------|
| `ansible_user` | `all.vars` | Fetched from Vault at runtime |
| `ansible_password` | `all.vars` | Fetched from Vault at runtime |
| `ansible_become_password` | `all.vars` | Same as `ansible_password` |
| `ansible_ssh_private_key_file` | `all.vars` | `~/.ssh/proxmox_vms` |
| `ansible_host` | per host | IP address of the host |

Proxmox nodes override `ansible_user` with `root`.

### Inventory Variables (services.yml)

| Variable | Where set | Description |
|----------|-----------|-------------|
| `vault_services` | per host | List of `{ name, dest }` pairs — which services' secrets to deploy and where |

---

## Docker Environment Files

Docker services read their runtime configuration from `.env` files deployed by Ansible onto each host. These files are located at `~/.secrets/<service>/.env` on the target host.

The table below shows which services use an `env_file` and what path it expects:

| Service | env_file path on host |
|---------|-----------------------|
| grafana | `~/.secrets/grafana/.env` |
| cloudflared | `~/.secrets/cloudflared/.env` |
| forgejo runner | `~/.secrets/forgejo/.env` |
| seafile + mariadb | `~/.secrets/seafile/.env` |
| homepage | `~/.secrets/homepage/.env` |
| rustfs | `~/.secrets/rustfs/.env` |
| adguard-sync | `~/.secrets/adguard_home_sync/.env` |

The exact keys inside each `.env` file depend on what you put into Vault via `terraform/vault/variables.tf`. The key names become environment variable names in the container.

Services that do **not** use an `env_file` (all config is in the compose file):

| Service | Configuration source |
|---------|---------------------|
| vaultwarden | `environment` block in compose file |
| navidrome | `environment` block in compose file |
| syncthing | No configuration needed |
| heimdall | `environment` block (PUID, PGID, TZ) |
| vault | `environment` block (VAULT_ADDR) |
| homelab-hub | No configuration needed |
