#!/bin/bash
set -e

# Source environment variables
source ./01-set-env-vars.sh

echo "================================================"
echo "Storing Azure AD Authorized Group ID in Key Vault"
echo "================================================"
echo ""
echo "Key Vault: ${KEYVAULT_NAME}"
echo "Authorized Group ID: ${AAD_AUTHORIZED_GROUP_ID}"
echo ""

# Validate input
if [ -z "$AAD_AUTHORIZED_GROUP_ID" ]; then
    echo "❌ Error: AAD_AUTHORIZED_GROUP_ID environment variable is required"
    echo "   Make sure AAD_AUTHORIZED_GROUP_ID is set in 01-set-env-vars.sh"
    exit 1
fi

echo "Storing authorized group ID in Key Vault..."

# Store Azure AD Authorized Group ID
az keyvault secret set \
    --vault-name "${KEYVAULT_NAME}" \
    --name "AAD-AUTHORIZED-GROUP-ID" \
    --value "${AAD_AUTHORIZED_GROUP_ID}" \
    --output none

echo "✓ Stored AAD-AUTHORIZED-GROUP-ID"

echo ""
echo "================================================"
echo "✅ Azure AD Group ID successfully stored in Key Vault"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Update the ExternalSecret resource (20-create-external-secret-resource.sh)"
echo "  2. Configure Airflow OAuth to check group membership"
echo ""
