#!/bin/bash

source .env

# Export variables for envsubst
export ACR_REGISTRY
export AKS_AIRFLOW_CLUSTER_NAME
export AKS_AIRFLOW_RESOURCE_GROUP
export AKS_AIRFLOW_NAMESPACE
export AKS_AIRFLOW_HELM_RELEASE_NAME

# Get AKS credentials
az aks get-credentials --resource-group $AKS_AIRFLOW_RESOURCE_GROUP --name $AKS_AIRFLOW_CLUSTER_NAME

# Check if Airflow release exists and uninstall if it does
if helm list -n $AKS_AIRFLOW_NAMESPACE | grep -q $AKS_AIRFLOW_HELM_RELEASE_NAME; then
    echo "Existing Airflow release found. Uninstalling..."
    helm uninstall $AKS_AIRFLOW_HELM_RELEASE_NAME -n $AKS_AIRFLOW_NAMESPACE
    echo "Waiting for pods to terminate..."
    kubectl wait --for=delete pods --all -n $AKS_AIRFLOW_NAMESPACE --timeout=300s
else
    echo "No existing Airflow release found. Proceeding with fresh install..."
fi

# Install Airflow using Helm
helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm search repo airflow

# Process the values file to substitute environment variables
echo "Processing airflow-values.yaml with environment variables..."
envsubst < airflow-values.yaml > airflow-values-processed.yaml

helm install $AKS_AIRFLOW_HELM_RELEASE_NAME apache-airflow/airflow --version 1.18.0 --namespace $AKS_AIRFLOW_NAMESPACE --create-namespace -f airflow-values-processed.yaml --debug

# Clean up the temporary processed values file
rm airflow-values-processed.yaml

# Verify the installation
kubectl get pods -n $AKS_AIRFLOW_NAMESPACE
kubectl get svc -n $AKS_AIRFLOW_NAMESPACE

# Port forward to access the Airflow API Server
echo "Pausing for 90 seconds to allow services to start..."
sleep 90
echo "You can access the Airflow webserver at http://localhost:8080"
kubectl port-forward svc/airflow-api-server 8080:8080 -n $AKS_AIRFLOW_NAMESPACE
