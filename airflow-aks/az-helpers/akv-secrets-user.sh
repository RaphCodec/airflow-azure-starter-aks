#!/bin/bash
# Grant Key Vault access to a managed identity or service principal
# Usage: ./grant-keyvault-access.sh <identity-client-id-or-app-id> [role]
# Example: ./grant-keyvault-access.sh 9465b82d-2a42-4f78-a5ee-bf44cd8927f8
# Example: ./grant-keyvault-access.sh 9465b82d-2a42-4f78-a5ee-bf44cd8927f8 "Key Vault Administrator"

set -e

# Check if identity ID is provided
if [ -z "$1" ]; then
    echo "❌ Error: Identity Client ID or Application ID is required"
    echo "Usage: $0 <identity-client-id-or-app-id> [role]"
    echo ""
    echo "Available roles:"
    echo "  - Key Vault Secrets User (default) - Read secrets"
    echo "  - Key Vault Secrets Officer - Read, write, delete secrets"
    echo "  - Key Vault Administrator - Full access"
    exit 1
fi

IDENTITY_ID="$1"
ROLE="${2:-Key Vault Secrets User}"

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../deploy-airflow/01-set-env-vars.sh" ]; then
    source "$SCRIPT_DIR/../deploy-airflow/01-set-env-vars.sh"
else
    echo "❌ Error: Could not find 01-set-env-vars.sh"
    exit 1
fi

echo "🔐 Granting Key Vault access..."
echo "   Identity: $IDENTITY_ID"
echo "   Role: $ROLE"
echo "   Key Vault: $KEYVAULT_NAME"
echo ""

# Grant the role assignment
az role assignment create \
  --role "$ROLE" \
  --assignee "$IDENTITY_ID" \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME"

echo ""
echo "✅ Successfully granted '$ROLE' role to identity $IDENTITY_ID"
echo "   Scope: Key Vault '$KEYVAULT_NAME'"
echo ""
echo "Note: Role assignments may take a few minutes to propagate."
