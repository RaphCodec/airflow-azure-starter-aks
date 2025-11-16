#!/bin/bash
set -e

# Source environment variables
source ./01-set-env-vars.sh

echo "================================================"
echo "Storing Azure AD Credentials in Key Vault"
echo "================================================"
echo ""
echo "Key Vault: ${KEYVAULT_NAME}"
echo "Tenant ID: ${AAD_TENANT_ID}"
echo "Client ID: ${AAD_CLIENT_ID}"
echo ""

# Prompt only for the client secret (sensitive credential)
read -sp "Enter Azure AD Client Secret: " AAD_CLIENT_SECRET
echo ""

# Validate inputs
if [ -z "$AAD_TENANT_ID" ] || [ -z "$AAD_CLIENT_ID" ] || [ -z "$AAD_CLIENT_SECRET" ]; then
    echo "❌ Error: All Azure AD credentials are required"
    echo "   Make sure AAD_TENANT_ID and AAD_CLIENT_ID are set in 01-set-env-vars.sh"
    exit 1
fi

echo ""
echo "Storing credentials in Key Vault..."

# Store Azure AD Tenant ID
az keyvault secret set \
    --vault-name "${KEYVAULT_NAME}" \
    --name "AAD-TENANT-ID" \
    --value "${AAD_TENANT_ID}" \
    --output none

echo "✓ Stored AAD-TENANT-ID"

# Store Azure AD Client ID
az keyvault secret set \
    --vault-name "${KEYVAULT_NAME}" \
    --name "AAD-CLIENT-ID" \
    --value "${AAD_CLIENT_ID}" \
    --output none

echo "✓ Stored AAD-CLIENT-ID"

# Store Azure AD Client Secret
az keyvault secret set \
    --vault-name "${KEYVAULT_NAME}" \
    --name "AAD-CLIENT-SECRET" \
    --value "${AAD_CLIENT_SECRET}" \
    --output none

echo "✓ Stored AAD-CLIENT-SECRET"

echo ""
echo "================================================"
echo "✓ Azure AD credentials stored successfully"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Manually create the 'azure-ad-credentials' ExternalSecret for Azure AD OAuth, or update ./19-create-external-secret-resource.sh to do so."
echo "2. Verify with: kubectl get externalsecret -n ${AKS_AIRFLOW_NAMESPACE}"
echo "3. Check secret: kubectl get secret azure-ad-credentials -n ${AKS_AIRFLOW_NAMESPACE}"
