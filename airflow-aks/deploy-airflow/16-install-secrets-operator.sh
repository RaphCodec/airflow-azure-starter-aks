helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets \
external-secrets/external-secrets \
--namespace ${AKS_AIRFLOW_NAMESPACE} \
--create-namespace \
--set installCRDs=true \
--wait