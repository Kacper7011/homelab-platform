#!/usr/bin/env bash

export VAULT_ADDR="http://10.10.10.216:8200"
export ANSIBLE_HASHI_VAULT_AUTH_METHOD=approle
export ANSIBLE_HASHI_VAULT_ROLE_ID="$(cat ~/.vault/ansible/role_id)"
export ANSIBLE_HASHI_VAULT_SECRET_ID="$(cat ~/.vault/ansible/secret_id)"