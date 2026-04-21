# Getting Started

This guide walks through setting up the entire platform from scratch, in the correct order. Each step depends on the previous one, so follow the sequence.

## Prerequisites

### Required Software

Install these tools on your local machine before you begin:

| Tool | Purpose |
|------|---------|
| Ansible | Runs playbooks to configure hosts and deploy secrets |
| `ansible-galaxy` | Installs the required Ansible collection |
| Terraform | Provisions Vault, Cloudflare, and RustFS resources |
| Docker + Docker Compose v2 | Runs all services on remote hosts |
| `vault` CLI | Needed for the secret ID refresh script |
| `jq` | Used by the credential refresh script |
| `ssh` | Access to all hosts |

Install the required Ansible collection:

```bash
ansible-galaxy collection install community.hashi_vault
```

### Required Accounts & Services

- A **Cloudflare account** with a registered domain and API access
- A **Proxmox cluster** with the hosts listed in the inventory already created

### SSH Access

Ansible uses an ed25519 SSH key to connect to VMs:

- Default key path: `~/.ssh/proxmox_vms_ed25519`
- This is set in `ansible/ansible.cfg` and `ansible/inventories/hosts.yml`

Make sure the public key is present on all target hosts before running any playbook.

---

## Bootstrap Order

### Step 1 — Start RustFS

RustFS provides the S3-compatible storage that Terraform uses to store its state files. It must be running before you can run `terraform init` for any module.

On `prox-services` (10.10.10.115):

```bash
cd docker/rustfs
docker compose up -d
```

### Step 2 — Terraform: Provision S3 Buckets

Create the S3 buckets that the other Terraform modules will use as backends.

```bash
cd terraform/rustfs
terraform init
terraform apply
```

This creates the following buckets: `docker`, `kubernetes`, `terraform`, `vault`, `seafile`, `misc`.

You need to provide the RustFS credentials. See [variables-reference.md](variables-reference.md) for the full list of variables for this module.

### Step 3 — Start Vault

Vault is the central secrets store. All other modules depend on it being available.

On `prox-vault` (10.10.10.216):

```bash
cd docker/vault
docker compose up -d
```

After starting, initialize and unseal Vault manually using the `vault` CLI or the web UI at `http://10.10.10.216:8200`. Save the root token — you will need it for the next step.

### Step 4 — Terraform: Configure Vault

This step creates everything inside Vault: the KV secrets engine, AppRole authentication, policies, and all service secrets.

```bash
cd terraform/vault
terraform init
terraform apply
```

You will need to provide your root token and all service environment variable maps. See [variables-reference.md](variables-reference.md) for the full list.

After this step, Vault contains:
- AppRole roles for `ansible` and `restic`
- All service secrets at `secret/data/services/<name>`
- The Ansible system user credentials at `secret/data/ansible/users`

### Step 5 — Configure Ansible Credentials

Ansible connects to Vault using AppRole authentication. You need two files on your local machine:

```
~/.vault/ansible/role_id     # The AppRole role ID (does not change)
~/.vault/ansible/secret_id   # A short-lived credential (rotated weekly)
```

Get the role ID from Terraform output or directly from Vault:

```bash
vault read auth/approle/role/ansible/role-id
```

Generate the initial secret ID:

```bash
vault write -f auth/approle/role/ansible/secret-id
```

Save both values to the files above.

Then set up the weekly rotation cron job. See [modules/scripts.md](modules/scripts.md) for details.

### Step 6 — Ansible: Deploy Secrets to Hosts

Before services can start, each host needs its `.env` files with the correct credentials. Ansible reads the secrets from Vault and writes them to the target hosts.

```bash
cd ansible

# Export credentials so Ansible can reach Vault
. ../scripts/ansible/ansible_export_vault_credentials.sh

# Deploy .env files to all service hosts
ansible-playbook -i inventories/services.yml playbooks/deploy-env-files.yml
```

This creates `~/.secrets/<service>/.env` on each target host.

### Step 7 — Start Docker Services

With secrets in place, you can start the Docker stacks. Each service must be started on its designated host. See [modules/docker.md](modules/docker.md) for the full list of which service runs where.

Example for `prox-services`:

```bash
cd docker/homepage && docker compose up -d
cd docker/seafile  && docker compose up -d
cd docker/forgejo  && docker compose up -d
cd docker/rustfs   && docker compose up -d
```

Example for `prox-gateway`:

```bash
cd docker/gateway      && docker compose up -d
cd docker/adguard-sync && docker compose up -d
```

Example for `prox-monitoring`:

```bash
cd docker/monitoring && docker compose up -d
```

### Step 8 — Terraform: Configure Cloudflare

Once the gateway service (Traefik + Cloudflared) is running, apply the Cloudflare module to create DNS records and configure the Zero Trust Tunnel.

```bash
cd terraform/cloudflare
terraform init
terraform apply
```

See [variables-reference.md](variables-reference.md) for the required Cloudflare variables.

---

## Day-to-Day Operations

**Deploy updated secrets** — run the `deploy-env-files.yml` playbook again, then restart the affected service.

**Rotate the Ansible secret ID** — this happens automatically via a weekly cron job. See [modules/scripts.md](modules/scripts.md).

**Add a new service** — add the service secrets to `terraform/vault/variables.tf` and `services.tf`, run `terraform apply`, add the service entry to `ansible/inventories/services.yml`, deploy env files, then add a compose file and start the container.

**Set up monitoring exporters** — run the relevant Ansible playbook for the new host. See [modules/ansible.md](modules/ansible.md).
