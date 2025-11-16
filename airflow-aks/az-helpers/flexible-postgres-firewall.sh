#!/usr/bin/env bash
set -euo pipefail

# Configure firewall rule for Azure PostgreSQL Flexible Server to allow Azure services
# Usage: source ../deploy-airflow/01-set-env-vars.sh then run this script

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source envs if available
if [ -f "$DIR/../deploy-airflow/01-set-env-vars.sh" ]; then
  # shellcheck disable=SC1090
  source "$DIR/../deploy-airflow/01-set-env-vars.sh"
fi

RESOURCE_GROUP="${RESOURCE_GROUP_NAME:-airflow-rg}"
POSTGRES_NAME="${POSTGRES_SERVER_NAME:-airflow-aks-pg-server}"

echo "Creating firewall rule for PostgreSQL Flexible Server: $POSTGRES_NAME"
az postgres flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$POSTGRES_NAME" \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

echo "✓ Firewall rule created successfully"
echo "  This allows Azure services (including AKS) to connect to PostgreSQL"