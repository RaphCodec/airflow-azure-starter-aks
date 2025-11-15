# create ADLS Gen2 (StorageV2 with hierarchical namespace)
az storage account create \
  --name "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$RESOURCE_LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --enable-hierarchical-namespace true \
  -o table

# get primary key (explicit resource-group)
export AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY=$(
  az storage account keys list \
    --account-name "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "[0].value" -o tsv
)

# create container
az storage container create \
  --name "$AKS_AIRFLOW_LOGS_STORAGE_CONTAINER_NAME" \
  --account-name "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME" \
  --account-key "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY" \
  -o table

# store values in Key Vault (vault must exist and caller must have permission)
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-NAME --value "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_NAME"
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name AKS-AIRFLOW-LOGS-STORAGE-ACCOUNT-KEY  --value "$AKS_AIRFLOW_LOGS_STORAGE_ACCOUNT_KEY"