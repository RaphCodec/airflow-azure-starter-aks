export KUBELET_IDENTITY=$(az aks show -g $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --output tsv --query identityProfile.kubeletidentity.objectId)
az role assignment create --assignee ${KUBELET_IDENTITY} --role "AcrPull" --scope ${ACR_REGISTRY_ID} --output table
