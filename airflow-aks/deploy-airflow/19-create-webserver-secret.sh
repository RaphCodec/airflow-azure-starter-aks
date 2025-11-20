#!/usr/bin/env bash
set -euo pipefail

# Generate an Airflow webserver secret and store it in Azure Key Vault.
# Usage: set the env var `KEYVAULT_NAME` (your Key Vault resource name) then run this script.

: "${KEYVAULT_NAME:?Environment variable KEYVAULT_NAME must be set (your Key Vault name)}"

# Name to use for the secret inside Key Vault (can be overridden)
WEB_SECRET_NAME="${WEB_SECRET_NAME:-airflow-webserver-secret-key}"

# Generate a secure 32-byte base64 secret (suitable for Flask/airflow SECRET_KEY)
WEB_SECRET_VALUE=$(openssl rand -base64 32)

echo "Storing webserver secret in Key Vault '$KEYVAULT_NAME' as secret name '$WEB_SECRET_NAME'..."
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "$WEB_SECRET_NAME" --value "$WEB_SECRET_VALUE" --only-show-errors

echo "Stored Key Vault secret: $WEB_SECRET_NAME"
echo "Note: ExternalSecret (or manual Kubernetes secret) should map Key Vault key '$WEB_SECRET_NAME' to a k8s secret key named 'webserver-secret-key'."

# For safety, don't print the full secret; show first & last few chars as a confirmation
echo "Secret preview: ${WEB_SECRET_VALUE:0:6}...${WEB_SECRET_VALUE: -6}"

echo "Done."