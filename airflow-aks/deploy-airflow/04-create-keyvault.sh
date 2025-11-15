az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP_NAME --location $RESOURCE_LOCATION --enable-rbac-authorization false --output table
export KEYVAULTID=$(az keyvault show --name $KEYVAULT_NAME --query "id" --output tsv)
export KEYVAULTURL=$(az keyvault show --name $KEYVAULT_NAME --query "properties.vaultUri" --output tsv)