#!/usr/bin/env bash

set -e

# Initial setup
#==============================
# mkdir -p ~/{scripts,.vault}
# crontab -e
# Add this line: 0 6 * * 0 /bin/bash ~/scripts/ansible_refresh_vault_credentials.sh
#==============================

# ========== Script ===========

ROOT_TOKEN=$(cat ~/.vault/root_token)
LOG_DATE=$(date +"%Y-%m-%d")

cd ~/homelab-platform/terraform/vault || { echo "Can't Enter ~/homelab-platform/terraform/vault"; exit 1; }

export VAULT_ADDR="http://10.10.10.216:8200"
export VAULT_TOKEN="$ROOT_TOKEN"

terraform destroy -target=vault_approle_auth_backend_role_secret_id.ansible -auto-approve
terraform apply -auto-approve

terraform output -raw ansible_secret_id > ~/.vault/ansible/secret_id
chmod 600 ~/.vault/ansible/secret_id

touch ~/.vault/ansible/ansible_refresh.log

echo "[ $LOG_DATE ] Ansible's secret_id has been refreshed" >> ~/.vault/ansible/ansible_refresh.log


