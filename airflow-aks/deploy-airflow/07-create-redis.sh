#!/usr/bin/env bash
set -euo pipefail

# Create Azure Cache for Redis and store keys/host in Key Vault
# Usage: source ./01-set-env-vars.sh then run this script

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source envs if available
if [ -f "$DIR/01-set-env-vars.sh" ]; then
  # shellcheck disable=SC1090
  source "$DIR/01-set-env-vars.sh"
fi

RESOURCE_GROUP="${RESOURCE_GROUP_NAME:-airflow-rg}"
LOCATION="${RESOURCE_LOCATION:-eastus2}"
REDIS_NAME="${REDIS_CACHE_NAME:-${REDIS_CACHE_NAME:-airflow-aks-redis-cache}}"
KEYVAULT_NAME="${KEYVAULT_NAME:-airflow-aks-vault}"

echo "Creating Azure Cache for Redis: $REDIS_NAME (rg: $RESOURCE_GROUP, location: $LOCATION)"
az redis create \
  --name "$REDIS_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard \
  --vm-size C1 \
  --output table

echo "Retrieving primary key and hostname..."
REDIS_KEY=$(az redis list-keys --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" --query primaryKey -o tsv)
REDIS_HOST=$(az redis show --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" --query hostName -o tsv)

if [ -z "$KEYVAULT_NAME" ]; then
  echo "KEYVAULT_NAME not set; skipping storing secrets in Key Vault."
  echo "Redis host: $REDIS_HOST"
  echo "Redis primary key: $REDIS_KEY"
else
  echo "Storing Redis host and key in Key Vault: $KEYVAULT_NAME"
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "REDIS-PRIMARY-KEY" --value "$REDIS_KEY" >/dev/null
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "REDIS-HOST" --value "$REDIS_HOST" >/dev/null
  echo "Secrets stored in Key Vault (names: REDIS-PRIMARY-KEY, REDIS-HOST)."
fi

echo "Redis creation complete."
