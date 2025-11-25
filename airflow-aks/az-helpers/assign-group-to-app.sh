#!/bin/bash
# Assign an Azure AD (Entra ID) group to an App Registration
# This allows members of the group to access the application
# Usage: ./assign-group-to-app.sh

set -e

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../deploy-airflow/01-set-env-vars.sh" ]; then
    source "$SCRIPT_DIR/../deploy-airflow/01-set-env-vars.sh"
else
    echo "❌ Error: Could not find 01-set-env-vars.sh"
    exit 1
fi

echo "================================================"
echo "Assign Azure AD Group to App Registration"
echo "================================================"
echo ""
echo "App Client ID: $AAD_CLIENT_ID"
echo "Group ID: $AAD_AUTHORIZED_GROUP_ID"
echo ""

# Validate required variables
if [ -z "$AAD_CLIENT_ID" ] || [ -z "$AAD_AUTHORIZED_GROUP_ID" ]; then
    echo "❌ Error: AAD_CLIENT_ID and AAD_AUTHORIZED_GROUP_ID must be set"
    echo "   Make sure these are configured in 01-set-env-vars.sh"
    exit 1
fi

# Get the service principal (enterprise app) ID
echo "Getting service principal ID..."
SP_ID=$(az ad sp show --id "$AAD_CLIENT_ID" --query id -o tsv)

if [ -z "$SP_ID" ]; then
    echo "❌ Error: Could not find service principal for app $AAD_CLIENT_ID"
    exit 1
fi

echo "✓ Service Principal ID: $SP_ID"
echo ""

# Get group details
echo "Getting group details..."
GROUP_NAME=$(az ad group show --group "$AAD_AUTHORIZED_GROUP_ID" --query displayName -o tsv)
echo "✓ Group Name: $GROUP_NAME"
echo ""

# Get available app roles
echo "Getting available app roles..."
APP_ROLES=$(az ad sp show --id "$SP_ID" --query "appRoles[?isEnabled==\`true\`].[id,displayName,value]" -o tsv)

if [ -z "$APP_ROLES" ]; then
    echo "❌ Error: No app roles found for this application"
    exit 1
fi

echo "Available app roles:"
echo "$APP_ROLES" | awk '{print "  - " $2 " (ID: " $1 ")"}'
echo ""

# Use the first available app role or prompt user
APP_ROLE_ID=$(echo "$APP_ROLES" | head -n1 | awk '{print $1}')
APP_ROLE_NAME=$(echo "$APP_ROLES" | head -n1 | awk '{print $2}')

echo "Using app role: $APP_ROLE_NAME"
echo ""

# Check if group is already assigned
echo "Checking if group is already assigned..."
EXISTING=$(az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SP_ID/appRoleAssignedTo" \
  --query "value[?principalId=='$AAD_AUTHORIZED_GROUP_ID'].id" -o tsv 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
    echo "⚠️  Group is already assigned to this app"
    read -p "Do you want to continue anyway? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# Assign the group to the app role
echo "Assigning group to app..."
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SP_ID/appRoleAssignedTo" \
  --headers "Content-Type=application/json" \
  --body "{\"principalId\":\"$AAD_AUTHORIZED_GROUP_ID\",\"resourceId\":\"$SP_ID\",\"appRoleId\":\"$APP_ROLE_ID\",\"principalType\":\"Group\"}" \
  --output none

echo ""
echo "================================================"
echo "✅ Group successfully assigned to app"
echo "================================================"
echo ""
echo "Group: $GROUP_NAME"
echo "App: $AAD_CLIENT_ID"
echo "Role: $APP_ROLE_NAME"
echo ""
echo "All members of this group can now access the application."
echo ""
