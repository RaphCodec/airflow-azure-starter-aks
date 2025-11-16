export IDENTITY_NAME_PRINCIPAL_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query principalId --output tsv)
export KEYVAULT_ID=$(az keyvault show --name $KEYVAULT_NAME --query id --output tsv)

# Use RBAC role assignment instead of access policy
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee-object-id $IDENTITY_NAME_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --scope $KEYVAULT_ID \
  --output table