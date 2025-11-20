#!/bin/bash
# Source environment variables
source 01-set-env-vars.sh

helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm search repo airflow

# Process the values file to substitute environment variables
echo "Processing airflow-values.yaml with environment variables..."
envsubst < airflow-values.yaml > airflow-values-processed.yaml


helm upgrade --install airflow apache-airflow/airflow --namespace airflow-demo --create-namespace -f airflow-values-processed.yaml --debug

# Clean up the temporary processed values file
rm airflow-values-processed.yaml