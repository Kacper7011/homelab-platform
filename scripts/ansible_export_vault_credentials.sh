#!/usr/bin/env bash
export VAULT_ADDR="http://10.10.10.216:8200"
export ANSIBLE_HASHI_VAULT_ROLE_ID="$(cat ~/.vault/role_id)"
export ANSIBLE_HASHI_VAULT_SECRET_ID="$(cat ~/.vault/secret_id)"