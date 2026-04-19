#!/usr/bin/env bash
# Move this script to /usr/local/bin and make it executable.
# It will fetch secrets from Vault and write them to /run/kopia-env for use by Kopia.
set -e

VAULT_ADDR="http://10.10.10.216:8200"
ROLE_ID="$(cat /root/.vault/kopia/role_id)"
SECRET_ID="$(cat /root/.vault/kopia/secret_id)"

# Auth via AppRole
VAULT_TOKEN=$(curl -sf \
  --request POST \
  --data "{\"role_id\":\"$ROLE_ID\",\"secret_id\":\"$SECRET_ID\"}" \
  $VAULT_ADDR/v1/auth/approle/login \
  | jq -r '.auth.client_token')

if [ -z "$VAULT_TOKEN" ]; then
  echo "ERROR: Unable to fetch token from Vault" >&2
  exit 1
fi

# Fetch Kopia secrets
SECRETS=$(curl -sf \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  $VAULT_ADDR/v1/secret/data/kopia/credentials)

ACCESS_KEY=$(echo $SECRETS | jq -r '.data.data.kopia.access_key')
SECRET_KEY=$(echo $SECRETS | jq -r '.data.data.kopia.secret_access_key')

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
  echo "ERROR: Unable to fetch secrets from Vault" >&2
  exit 1
fi

# Write to /run (tmpfs - disappears after restart)
cat > /run/kopia-env << ENVEOF
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$SECRET_KEY
ENVEOF

chmod 600 /run/kopia-env
echo "Secrets fetched successfully"