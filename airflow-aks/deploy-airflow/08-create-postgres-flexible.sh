#!/usr/bin/env bash
set -euo pipefail

# Create Azure Database for PostgreSQL - Flexible Server, create a DB, and store password/connection string in Key Vault
# Usage: source ./01-set-env-vars.sh then run this script

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source envs if available
if [ -f "$DIR/01-set-env-vars.sh" ]; then
  # shellcheck disable=SC1090
  source "$DIR/01-set-env-vars.sh"
fi

RESOURCE_GROUP="${RESOURCE_GROUP_NAME:-airflow-rg}"
LOCATION="${RESOURCE_LOCATION:-eastus2}"
POSTGRES_NAME="${POSTGRES_SERVER_NAME:-airflow-aks-pg-server}"
KEYVAULT_NAME="${KEYVAULT_NAME:-airflow-aks-vault}"
POSTGRES_ADMIN_USER="${POSTGRES_ADMIN_USER:-pgadmin}"

# If admin password not provided via env, generate a secure one and store it in Key Vault
if [ -z "${POSTGRES_ADMIN_PASSWORD-}" ]; then
  if command -v openssl >/dev/null 2>&1; then
    POSTGRES_ADMIN_PASSWORD=$(openssl rand -base64 18)
  else
    POSTGRES_ADMIN_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20 || echo "ChangeMe123!")
  fi
  echo "Generated a PostgreSQL admin password and storing in Key Vault (if available)."
  if [ -n "$KEYVAULT_NAME" ]; then
    az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-ADMIN-PASSWORD" --value "$POSTGRES_ADMIN_PASSWORD" >/dev/null
  else
    echo "No KEYVAULT_NAME; admin password will not be stored in Key Vault."
  fi
fi

echo "Creating PostgreSQL Flexible Server: $POSTGRES_NAME (rg: $RESOURCE_GROUP, location: $LOCATION)"
az postgres flexible-server create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$POSTGRES_NAME" \
  --location "$LOCATION" \
  --admin-user "$POSTGRES_ADMIN_USER" \
  --admin-password "$POSTGRES_ADMIN_PASSWORD" \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 15 \
  -o table

DB_NAME="airflow"

echo "Creating database '$DB_NAME' on server $POSTGRES_NAME"
az postgres flexible-server db create --resource-group "$RESOURCE_GROUP" --server-name "$POSTGRES_NAME" --database-name "$DB_NAME"

# Build connection string and store in Key Vault
HOSTNAME=$(az postgres flexible-server show --resource-group "$RESOURCE_GROUP" --name "$POSTGRES_NAME" --query fullyQualifiedDomainName -o tsv)
CONN="postgresql://${POSTGRES_ADMIN_USER}:${POSTGRES_ADMIN_PASSWORD}@${HOSTNAME}:5432/${DB_NAME}"

if [ -n "$KEYVAULT_NAME" ]; then
  echo "Storing PostgreSQL connection string in Key Vault: $KEYVAULT_NAME"
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-CONNECTION-STRING" --value "$CONN" >/dev/null
else
  echo "No KEYVAULT_NAME set; here's the connection string (keep it secret):"
  echo "$CONN"
fi

echo "Postgres flexible server creation complete."
