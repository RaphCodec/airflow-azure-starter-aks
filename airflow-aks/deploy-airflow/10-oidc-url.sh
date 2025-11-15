export OIDC_URL=$(az aks show --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --query oidcIssuerProfile.issuerUrl --output tsv)
