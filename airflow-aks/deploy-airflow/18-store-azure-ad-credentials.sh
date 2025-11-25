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
echo "Authorized Group ID: ${AAD_AUTHORIZED_GROUP_ID}"
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

if [ -z "$AAD_AUTHORIZED_GROUP_ID" ]; then
    echo "⚠️  Warning: AAD_AUTHORIZED_GROUP_ID not set"
    echo "   Group-based access control will not be enabled"
    echo ""
    read -p "Continue without group ID? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi
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

# Store Azure AD Authorized Group ID (if provided)
if [ -n "$AAD_AUTHORIZED_GROUP_ID" ]; then
    az keyvault secret set \
        --vault-name "${KEYVAULT_NAME}" \
        --name "AAD-AUTHORIZED-GROUP-ID" \
        --value "${AAD_AUTHORIZED_GROUP_ID}" \
        --output none
    
    echo "✓ Stored AAD-AUTHORIZED-GROUP-ID"
fi

echo ""
echo "================================================"
echo "✅ Azure AD credentials stored successfully"
echo "================================================"
echo ""
echo "Stored credentials:"
echo "  - AAD-TENANT-ID"
echo "  - AAD-CLIENT-ID"
echo "  - AAD-CLIENT-SECRET"
if [ -n "$AAD_AUTHORIZED_GROUP_ID" ]; then
    echo "  - AAD-AUTHORIZED-GROUP-ID"
fi
echo ""
echo "Next steps:"
echo "  1. Update the ExternalSecret resource (./20-create-external-secret-resource.sh)"
echo "  2. Verify: kubectl get externalsecret -n ${AKS_AIRFLOW_NAMESPACE}"
echo "  3. Check secret: kubectl get secret azure-ad-credentials -n ${AKS_AIRFLOW_NAMESPACE}"
echo ""
