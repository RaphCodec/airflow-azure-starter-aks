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
DB_NAME="${POSTGRES_DATABASE_NAME:-airflow}"

# Check if server already exists
SERVER_EXISTS=$(az postgres flexible-server show --resource-group "$RESOURCE_GROUP" --name "$POSTGRES_NAME" --query "name" -o tsv 2>/dev/null || echo "")

if [ -n "$SERVER_EXISTS" ]; then
  echo "PostgreSQL Flexible Server '$POSTGRES_NAME' already exists."
  echo "Retrieving existing server details..."
  
  # Try to get password from Key Vault if it exists
  if [ -n "$KEYVAULT_NAME" ]; then
    POSTGRES_ADMIN_PASSWORD=$(az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "POSTGRES-ADMIN-PASSWORD" --query value -o tsv 2>/dev/null || echo "")
    if [ -z "$POSTGRES_ADMIN_PASSWORD" ]; then
      echo ""
      echo "⚠️  Password not found in Key Vault."
      echo "Please provide the PostgreSQL admin password for user '$POSTGRES_ADMIN_USER':"
      read -s POSTGRES_ADMIN_PASSWORD
      echo ""
    else
      echo "✓ Retrieved password from Key Vault"
    fi
  else
    echo "Please provide the PostgreSQL admin password for user '$POSTGRES_ADMIN_USER':"
    read -s POSTGRES_ADMIN_PASSWORD
    echo ""
  fi
else
  echo "Creating new PostgreSQL Flexible Server: $POSTGRES_NAME"

  echo "Creating new PostgreSQL Flexible Server: $POSTGRES_NAME"
  
  # If admin password not provided via env, generate a secure one
  if [ -z "${POSTGRES_ADMIN_PASSWORD-}" ]; then
    if command -v openssl >/dev/null 2>&1; then
      POSTGRES_ADMIN_PASSWORD=$(openssl rand -base64 18)
    else
      POSTGRES_ADMIN_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20 || echo "ChangeMe123!")
    fi
    echo "Generated a PostgreSQL admin password"
  fi

  # Store password in Key Vault before creating server
  if [ -n "$KEYVAULT_NAME" ]; then
    az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-ADMIN-PASSWORD" --value "$POSTGRES_ADMIN_PASSWORD" --output none
    echo "✓ Password stored in Key Vault"
  fi

  echo "Creating PostgreSQL Flexible Server (this may take several minutes)..."
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
fi

# Ensure database exists
echo "Checking/creating database '$DB_NAME' on server $POSTGRES_NAME..."
az postgres flexible-server db create --resource-group "$RESOURCE_GROUP" --server-name "$POSTGRES_NAME" --database-name "$DB_NAME" 2>/dev/null || echo "Database '$DB_NAME' already exists"

# Build connection string and store in Key Vault
HOSTNAME=$(az postgres flexible-server show --resource-group "$RESOURCE_GROUP" --name "$POSTGRES_NAME" --query fullyQualifiedDomainName -o tsv)
CONN="postgresql://${POSTGRES_ADMIN_USER}:${POSTGRES_ADMIN_PASSWORD}@${HOSTNAME}:5432/${DB_NAME}?sslmode=require"

if [ -n "$KEYVAULT_NAME" ]; then
  echo "Storing PostgreSQL connection details in Key Vault: $KEYVAULT_NAME"
  # Store individual components for External Secrets templating
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-HOST" --value "$HOSTNAME" --output none
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-USER" --value "$POSTGRES_ADMIN_USER" --output none
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-PASSWORD" --value "$POSTGRES_ADMIN_PASSWORD" --output none
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-DATABASE" --value "$DB_NAME" --output none
  # Also store full connection string for reference
  az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "POSTGRES-CONNECTION-STRING" --value "$CONN" --output none
  echo "✓ PostgreSQL secrets stored in Key Vault:"
  echo "  - POSTGRES-HOST"
  echo "  - POSTGRES-USER"
  echo "  - POSTGRES-PASSWORD"
  echo "  - POSTGRES-DATABASE"
  echo "  - POSTGRES-CONNECTION-STRING"
else
  echo "No KEYVAULT_NAME set; here's the connection string (keep it secret):"
  echo "$CONN"
fi

echo ""
echo "✓ Postgres flexible server creation complete."
echo "  Server: $POSTGRES_NAME"
echo "  Database: $DB_NAME"
echo "  Host: $HOSTNAME"
echo ""