az identity create --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --output table
export IDENTITY_NAME_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv)
export IDENTITY_NAME_PRINCIPAL_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query principalId --output tsv)
export IDENTITY_NAME_CLIENT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query clientId --output tsv)