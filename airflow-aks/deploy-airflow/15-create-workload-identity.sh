export TENANT_ID=$(az account show --query tenantId -o tsv)

# Ensure IDENTITY_NAME_CLIENT_ID is set
if [ -z "$IDENTITY_NAME_CLIENT_ID" ]; then
  export IDENTITY_NAME_CLIENT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query clientId --output tsv)
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${IDENTITY_NAME_CLIENT_ID}"
    azure.workload.identity/tenant-id: "${AAD_TENANT_ID}"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${AKS_AIRFLOW_NAMESPACE}"
EOF