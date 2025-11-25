#!/bin/bash
# Grant Admin role to a user in Airflow using kubectl and Airflow CLI
# Usage: ./grant-admin-access.sh <username-or-email>

set -e

# Source environment variables
source ./01-set-env-vars.sh

# Check if username is provided
if [ -z "$1" ]; then
    echo "❌ Error: Username or email is required"
    echo "Usage: $0 <username-or-email>"
    echo ""
    echo "Example:"
    echo "  $0 user@example.com"
    echo "  $0 testuser@yourdomain.onmicrosoft.com"
    exit 1
fi

USERNAME="$1"

echo "================================================"
echo "Grant Airflow Admin Access"
echo "================================================"
echo ""
echo "Namespace: $AKS_AIRFLOW_NAMESPACE"
echo "User: $USERNAME"
echo ""

# Get the API server pod
echo "Getting API server pod..."
API_SERVER_POD=$(kubectl get pods -n "$AKS_AIRFLOW_NAMESPACE" -l component=api-server -o jsonpath='{.items[0].metadata.name}')

if [ -z "$API_SERVER_POD" ]; then
    echo "❌ Error: Could not find API server pod"
    exit 1
fi

echo "✓ API Server Pod: $API_SERVER_POD"
echo ""

# List current users
echo "Current Airflow users:"
echo "----------------------------------------"
kubectl exec -n "$AKS_AIRFLOW_NAMESPACE" "$API_SERVER_POD" -- airflow users list
echo ""

# Check if user exists
echo "Checking if user '$USERNAME' exists..."
USER_EXISTS=$(kubectl exec -n "$AKS_AIRFLOW_NAMESPACE" "$API_SERVER_POD" -- \
    airflow users list 2>/dev/null | grep -i "$USERNAME" || echo "")

if [ -z "$USER_EXISTS" ]; then
    echo "⚠️  User '$USERNAME' not found in Airflow"
    echo ""
    echo "The user needs to log in via Azure AD OAuth at least once before"
    echo "they can be granted Admin access."
    echo ""
    read -p "Do you want to continue anyway? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# Grant Admin role
echo "Granting Admin role to user '$USERNAME'..."
kubectl exec -n "$AKS_AIRFLOW_NAMESPACE" "$API_SERVER_POD" -- \
    airflow users add-role -u "$USERNAME" -r Admin

echo ""
echo "================================================"
echo "✅ Admin role granted successfully"
echo "================================================"
echo ""
echo "User '$USERNAME' now has Admin access to Airflow."
echo "They may need to log out and log back in to see the changes."
echo ""
