# Ansible

## Overview

Ansible is used to configure hosts and deploy secrets to them. It does not manage Docker containers directly — it only prepares the environment so that Docker services can start.

All playbooks are in `ansible/playbooks/`. All roles are in `ansible/roles/`. Configuration is in `ansible/ansible.cfg`.

## Dependencies

### Required Collections

```bash
ansible-galaxy collection install community.hashi_vault
```

This collection provides the `hashi_vault` lookup plugin, which Ansible uses to read secrets from Vault at runtime.

### SSH Key

Ansible connects to all hosts using an ed25519 SSH key:

- Path: `~/.ssh/proxmox_vms_ed25519`
- This is set in `ansible/ansible.cfg` under `private_key_file`

Make sure this key's public part is present on each target host.

### Vault Credentials

Before running any playbook, you must export Vault credentials for the current shell session. Use the export script:

```bash
. scripts/ansible/ansible_export_vault_credentials.sh
```

This sets the following environment variables:

| Variable | Value |
|----------|-------|
| `VAULT_ADDR` | `http://10.10.10.216:8200` |
| `ANSIBLE_HASHI_VAULT_AUTH_METHOD` | `approle` |
| `ANSIBLE_HASHI_VAULT_ROLE_ID` | read from `~/.vault/ansible/role_id` |
| `ANSIBLE_HASHI_VAULT_SECRET_ID` | read from `~/.vault/ansible/secret_id` |

The `role_id` and `secret_id` files must exist before you run the script. See [secrets.md](../secrets.md) for how to create them.

---

## Inventory Files

### hosts.yml

`ansible/inventories/hosts.yml` defines all hosts and groups. It is used by most playbooks.

Groups:
- `proxmox_nodes` — the three Proxmox hypervisor nodes (connect as `root`)
- `virtual_machines` — VMs running Docker services
- `k3s_cluster / control_planes` — the K3s control plane node

The default SSH user and password for VMs are fetched from Vault at runtime:

```yaml
ansible_user: "{{ lookup('community.hashi_vault.hashi_vault', 'secret/data/ansible/users').sys_user.username }}"
ansible_password: "{{ lookup('community.hashi_vault.hashi_vault', 'secret/data/ansible/users').sys_user.password }}"
```

### services.yml

`ansible/inventories/services.yml` maps each host to the list of services whose secrets it needs. Used only by the `deploy-env-files.yml` playbook.

Each host entry includes a `vault_services` list:

```yaml
prox-services:
  vault_services:
    - name: homepage
      dest: "/home/{{ ansible_user }}/.secrets/homepage"
    - name: seafile
      dest: "/home/{{ ansible_user }}/.secrets/seafile"
```

### restic-backups.yml

`ansible/inventories/restic-backups.yml` lists the four hosts that need backup agents deployed:

- `prox-services` (10.10.10.115)
- `prox-monitoring` (10.10.10.107)
- `prox-vault` (10.10.10.216)
- `prox-management` (10.10.10.121)

---

## Playbooks

All playbooks are run from the `ansible/` directory.

| Playbook | Inventory | What it does |
|----------|-----------|--------------|
| `deploy-env-files.yml` | `services.yml` | Reads secrets from Vault and writes `.env` files to each host |
| `node-exporter-setup.yml` | `hosts.yml` | Installs and starts the Prometheus node exporter on all hosts |
| `promtail-setup-vm.yml` | `hosts.yml` | Deploys the Loki log agent on VMs |
| `promtail-setup-prox.yml` | `hosts.yml` | Deploys the Loki log agent on Proxmox nodes |
| `proxmox-exporter-setup.yml` | `hosts.yml` | Installs the Proxmox VE metrics exporter |
| `cadvisor-setup.yml` | `hosts.yml` | Deploys cAdvisor (container metrics) via a compose file |
| `restic-backup.yml` | `restic-backups.yml` | Deploys restic backup scripts and configuration |
| `vm-setup.yml` | `hosts.yml` | Runs the bootstrap role on new VMs |
| `k3s-cluster-setup.yml` | `hosts.yml` | Sets up K3s control plane and agent nodes |

---

## Roles

### bootstrap

`ansible/roles/bootstrap/` — runs on new VMs to prepare the system.

Tasks:
- Updates packages
- Creates the system user (credentials from Vault)
- Configures sudo access
- Deploys SSH public keys
- Sets the correct timezone

### docker

`ansible/roles/docker/` — installs Docker on a host.

Tasks:
- Adds Docker's official GPG key and APT repository
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-compose-plugin`
- Enables and starts the Docker systemd service

### k3s-server

`ansible/roles/k3s-server/` — sets up a K3s control plane node.

### k3s-agent

`ansible/roles/k3s-agent/` — joins a node to an existing K3s cluster as a worker.

---

## Running Playbooks

Always run playbooks from the `ansible/` directory and source the Vault credentials first:

```bash
cd ansible
. ../scripts/ansible/ansible_export_vault_credentials.sh

# Deploy secrets to service hosts
ansible-playbook -i inventories/services.yml playbooks/deploy-env-files.yml

# Install node exporter on all hosts
ansible-playbook -i inventories/hosts.yml playbooks/node-exporter-setup.yml

# Deploy promtail to VMs
ansible-playbook -i inventories/hosts.yml playbooks/promtail-setup-vm.yml

# Deploy restic backup agents
ansible-playbook -i inventories/restic-backups.yml playbooks/restic-backup.yml

# Prepare a new VM
ansible-playbook -i inventories/hosts.yml playbooks/vm-setup.yml --limit prox-services
```

To run a playbook against a single host, use `--limit <hostname>`.
