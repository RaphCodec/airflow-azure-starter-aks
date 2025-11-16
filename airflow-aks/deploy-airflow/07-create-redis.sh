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
REDIS_NAME="${REDIS_CACHE_NAME:-airflow-aks-redis-cache}"
KEYVAULT_NAME="${KEYVAULT_NAME:-airflow-aks-vault}"

# Validate required variables
if [ -z "$RESOURCE_GROUP" ]; then
  echo "ERROR: RESOURCE_GROUP_NAME is not set. Please source 01-set-env-vars.sh first."
  exit 1
fi

echo "Creating Azure Cache for Redis: $REDIS_NAME (rg: $RESOURCE_GROUP, location: $LOCATION)"
az redis create \
  --name "$REDIS_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard \
  --vm-size C1 \
  --output table

echo "Retrieving primary key and hostname..."
REDIS_KEY=$(az redis list-keys --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" --query primaryKey -o tsv 2>/dev/null)
REDIS_HOST=$(az redis show --name "$REDIS_NAME" --resource-group "$RESOURCE_GROUP" --query hostName -o tsv 2>/dev/null)

if [ -z "$REDIS_KEY" ] || [ -z "$REDIS_HOST" ]; then
  echo "ERROR: Failed to retrieve Redis credentials."
  echo "  Please verify that Redis cache '$REDIS_NAME' exists in resource group '$RESOURCE_GROUP'"
  echo "  Run: az redis show -g $RESOURCE_GROUP -n $REDIS_NAME"
  exit 1
fi

echo "  Redis Host: $REDIS_HOST"
echo "  Redis Key: ${REDIS_KEY:0:10}..." # Show only first 10 chars for security

if [ -z "$KEYVAULT_NAME" ]; then
  echo "KEYVAULT_NAME not set; skipping storing secrets in Key Vault."
  echo "Redis host: $REDIS_HOST"
  echo "Redis primary key: $REDIS_KEY"
else
  echo "Storing Redis host and key in Key Vault: $KEYVAULT_NAME"
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "REDIS-PRIMARY-KEY" --value "$REDIS_KEY" --output none
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "REDIS-HOST" --value "$REDIS_HOST" --output none
  echo "✓ Secrets stored in Key Vault (names: REDIS-PRIMARY-KEY, REDIS-HOST)."
fi

echo ""
echo "✓ Redis creation complete."
echo "  Name: $REDIS_NAME"
echo "  Host: $REDIS_HOST"
echo "  Port (SSL): 6380"
echo ""
echo "Next steps:"
echo "  1. Run ./18-create-external-secret-resource.sh to sync secrets to Kubernetes"
echo "  2. Run ./23-install-airflow.sh to deploy Airflow with Azure Redis"

