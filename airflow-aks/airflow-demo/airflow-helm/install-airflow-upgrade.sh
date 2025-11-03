#!/bin/bash

source .env

# Get AKS credentials
az aks get-credentials --resource-group $AKS_AIRFLOW_RESOURCE_GROUP --name $AKS_AIRFLOW_CLUSTER_NAME

# Add and update Helm repo
helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm search repo airflow

# Use upgrade --install to handle both new installs and upgrades
helm upgrade --install $AKS_AIRFLOW_HELM_RELEASE_NAME apache-airflow/airflow \
    --namespace $AKS_AIRFLOW_NAMESPACE \
    --create-namespace \
    -f airflow-values.yaml \
    --debug