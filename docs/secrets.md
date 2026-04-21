# Secrets Management

## Overview

All secrets in this project are stored in **HashiCorp Vault**. No credentials are stored in this repository or in plain text on any host (except the files listed below, which are kept outside the repo under `~/.vault/`).

The flow looks like this:

1. Secrets are written to Vault by running `terraform apply` in `terraform/vault/`
2. Ansible reads those secrets from Vault at playbook runtime and writes them as `.env` files on target hosts
3. Docker services read their credentials from `~/.secrets/<service>/.env` at startup

## Vault Secret Structure

All secrets live under the `secret/` KV v2 engine. The paths are:

```
secret/data/
├── ansible/
│   └── users/
│       └── sys_user        # { username, password } — used by Ansible to SSH into hosts
└── services/
    ├── homepage/            # env vars for the homepage container
    ├── seafile/             # env vars for seafile, mariadb
    ├── forgejo/             # env vars for the forgejo runner (FORGEJO_RUNNER_REGISTRATION_TOKEN)
    ├── cloudflared/         # { TUNNEL_TOKEN }
    ├── adguard_home_sync/   # env vars for AdGuard Sync
    ├── grafana/             # env vars for Grafana
    ├── rustfs/              # env vars for RustFS (access key, secret key)
    └── restic/
        └── credentials/    # { access_key, secret_access_key, repo_password }
```

Each service's secret is a flat key-value map. The keys become environment variable names in the `.env` file.

## AppRole Authentication

Vault uses **AppRole** as the authentication method for Ansible. AppRole is a machine-oriented auth method — instead of a username and password, you use two values:

- **Role ID** — a static identifier for the role, similar to a username. It does not expire.
- **Secret ID** — a short-lived credential, similar to a password. It expires after 10 days (`secret_id_ttl = 864000` seconds).

Two AppRole roles are configured:

| Role | Access |
|------|--------|
| `ansible` | Read access to `secret/data/ansible/*` and `secret/data/services/*` |
| `restic` | Read-only access to `secret/data/services/restic/credentials` |

### Credential Files on Disk

Ansible reads its Vault credentials from these local files:

```
~/.vault/ansible/role_id     # Static, set once after terraform apply
~/.vault/ansible/secret_id   # Rotated weekly by the cron script
```

These files must exist before running any Ansible playbook that connects to Vault.

### Secret ID Rotation

The secret ID expires every 10 days. A cron job runs every Sunday at 06:00 to generate a new one:

```
0 6 * * 0  /bin/bash ~/scripts/ansible_refresh_vault_credentials.sh
```

The script uses the Vault root token (stored at `~/.vault/root_token`) to generate a new secret ID and overwrite `~/.vault/ansible/secret_id`. It also writes a log entry to `~/.vault/ansible/ansible_refresh.log`.

See [modules/scripts.md](modules/scripts.md) for the full script description and setup instructions.

## How Ansible Injects Secrets into Hosts

The `deploy-env-files.yml` playbook does the following for each service listed in `inventories/services.yml`:

1. Creates the directory `~/.secrets/<service>/` on the target host (mode `0750`)
2. Reads the service secrets from Vault using the `community.hashi_vault.hashi_vault` lookup
3. Renders the secrets into a `.env` file using the `env.j2` template (mode `0600`)

The resulting file looks like this:

```
KEY_ONE=value1
KEY_TWO=value2
```

Docker Compose picks up this file via the `env_file` directive in each compose file:

```yaml
env_file:
  - ~/.secrets/<service>/.env
```

## Security Notes

- **Never commit** `terraform.tfvars` files — they contain all service secrets in plain text
- **Never commit** `~/.vault/root_token` or any secret ID
- The `.gitignore` already excludes `*.tfvars` and `*.tfstate` files
- The `.env` files on target hosts are only readable by the service user (mode `0600`)
- The `~/.secrets/` directories are only accessible by the owner (mode `0750`)
