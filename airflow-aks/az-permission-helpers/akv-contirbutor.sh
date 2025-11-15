az role assignment create \
  --role "Key Vault Contributor" \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --scope $(az keyvault show --name $KEYVAULT_NAME --query id -o tsv)