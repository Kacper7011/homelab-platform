# Terraform

## Overview

Terraform manages three separate modules in this project. Each module is in its own directory under `terraform/` and has its own state file stored in RustFS.

| Module | Directory | What it manages |
|--------|-----------|-----------------|
| RustFS buckets | `terraform/rustfs/` | S3 buckets and IAM users in RustFS |
| Vault | `terraform/vault/` | Secrets, AppRoles, and policies in Vault |
| Cloudflare | `terraform/cloudflare/` | DNS records and Zero Trust Tunnel |

---

## S3 Backend (RustFS)

All three modules store their Terraform state in RustFS, which acts as an S3-compatible backend.

Backend configuration (example from the `vault` module):

```hcl
backend "s3" {
  bucket   = "terraform"
  key      = "vault/terraform.tfstate"
  region   = "us-east-1"
  endpoint = "http://10.10.10.115:9020"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  force_path_style            = true
}
```

Each module uses a different `key` in the same `terraform` bucket:
- `rustfs` → `rustfs/terraform.tfstate`
- `vault` → `vault/terraform.tfstate`
- `cloudflare` → `cloudflare/terraform.tfstate`

Before running `terraform init`, export your RustFS credentials:

```bash
. scripts/rustfs/rustfs_export_credentials.sh
```

---

## Module: rustfs/

### Resources Created

- Six S3 buckets: `docker`, `kubernetes`, `terraform`, `vault`, `seafile`, `misc`
- A `restic` IAM user with access to the `vault` bucket (for backups)

### Variables

Create a `terraform.tfvars` file inside `terraform/rustfs/`:

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `rustfs_access_key` | Admin access key for RustFS | No |
| `rustfs_secret_key` | Admin secret key for RustFS | Yes |
| `rustfs_address` | Full URL of RustFS (e.g. `http://10.10.10.115:9020`) | No |
| `rustfs_host` | Host:port without scheme (e.g. `10.10.10.115:9020`) | No |
| `restic_secret` | Secret key to create for the restic IAM user | Yes |

### Usage

```bash
cd terraform/rustfs
. ../../scripts/rustfs/rustfs_export_credentials.sh
terraform init
terraform apply
```

---

## Module: vault/

### Resources Created

- KV v2 secrets engine at path `secret/`
- AppRole auth backend with two roles: `ansible` and `restic`
- Vault policies for each role
- All service secrets under `secret/data/services/<name>`
- Ansible system user credentials under `secret/data/ansible/users`
- SSH key pair for Ansible

### Variables

Create a `terraform.tfvars` file inside `terraform/vault/`:

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `vault_address` | Vault server URL | No |
| `root_token` | Vault root token | Yes |
| `sys_user_username` | Username for the Ansible system user | No |
| `sys_user_password` | Password for the Ansible system user | Yes |
| `restic_access_key` | Access key stored in Vault for restic | No |
| `restic_secret_access_key` | Secret key stored in Vault for restic | Yes |
| `restic_repo_password` | Encryption password for the restic repository | Yes |
| `ansible_ssh_private_key` | Private SSH key for Ansible | Yes |
| `ansible_ssh_public_key` | Public SSH key for Ansible | No |
| `homepage_env` | Map of env vars for the homepage service | Yes |
| `seafile_env` | Map of env vars for seafile and MariaDB | Yes |
| `forgejo_env` | Map of env vars for the Forgejo runner | Yes |
| `cloudflared_env` | Map of env vars for Cloudflared (`TUNNEL_TOKEN`) | Yes |
| `adguard_home_sync_env` | Map of env vars for AdGuard Sync | Yes |
| `grafana_env` | Map of env vars for Grafana | Yes |
| `rustfs_env` | Map of env vars for RustFS | Yes |

Each `*_env` variable is a `map(string)`. Example:

```hcl
homepage_env = {
  HOMEPAGE_VAR_KEY = "value"
}
```

### Usage

```bash
cd terraform/vault
. ../../scripts/rustfs/rustfs_export_credentials.sh
terraform init
terraform apply
```

---

## Module: cloudflare/

### Resources Created

- A Cloudflare Zero Trust Tunnel named `homelab_tunnel`
- Tunnel ingress rules routing each service hostname to `http://traefik:80`
- CNAME DNS records pointing each service subdomain to the tunnel endpoint
- A fallback rule returning HTTP 404 for unknown hostnames

### Variables

Create a `terraform.tfvars` file inside `terraform/cloudflare/`:

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `cloudflare_api_token` | Cloudflare API token with DNS and tunnel permissions | Yes |
| `cloudflare_zone_id` | Zone ID of your domain in Cloudflare | No |
| `cloudflare_account_id` | Cloudflare account ID | No |
| `cloudflare_tunnel_secret` | Secret used when creating the tunnel | Yes |
| `domain_name` | Your public domain (e.g. `example.com`) | No |

### Usage

```bash
cd terraform/cloudflare
. ../../scripts/rustfs/rustfs_export_credentials.sh
terraform init
terraform apply
```

The gateway service (Traefik + Cloudflared) must be running before applying this module, because the tunnel token written to Vault by the `vault` module needs to match the tunnel created here.

---

## Apply Order

1. **rustfs** — creates the S3 buckets used as Terraform backends by the other two modules
2. **vault** — requires RustFS to be running (backend) and Vault to be initialized and unsealed
3. **cloudflare** — requires RustFS (backend) and the gateway service to be running
