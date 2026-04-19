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
LOG_FILE=~/.vault/ansible/ansible_refresh.log

export VAULT_ADDR="http://10.10.10.216:8200"
export VAULT_TOKEN="$ROOT_TOKEN"

vault write -f auth/approle/role/ansible/secret-id -format=json \
    | jq -r '.data.secret_id' > ~/.vault/ansible/secret_id
chmod 600 ~/.vault/ansible/secret_id

touch "$LOG_FILE"
echo "[ $LOG_DATE ] Ansible's secret_id has been refreshed" >> "$LOG_FILE"


