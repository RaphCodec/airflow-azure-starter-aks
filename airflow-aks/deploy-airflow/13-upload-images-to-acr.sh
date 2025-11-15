az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:airflow-pgbouncer-2025.03.05-1.23.1 --image airflow:airflow-pgbouncer-2025.03.05-1.23.1
az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:airflow-pgbouncer-exporter-2025.03.05-0.18.0 --image airflow:airflow-pgbouncer-exporter-2025.03.05-0.18.0
az acr import --name $MY_ACR_REGISTRY --source docker.io/bitnamilegacy/postgresql:16.1.0-debian-11-r15 --image postgresql:16.1.0-debian-11-r15
az acr import --name $MY_ACR_REGISTRY --source docker.io/library/redis:7.4.1-alpine --image redis:7.4.1-alpine
az acr import --name $MY_ACR_REGISTRY --source quay.io/prometheus/statsd-exporter:v0.28.0 --image statsd-exporter:v0.28.0 
az acr import --name $MY_ACR_REGISTRY --source docker.io/apache/airflow:3.0.2 --image airflow:3.0.2 
az acr import --name $MY_ACR_REGISTRY --source registry.k8s.io/git-sync/git-sync:v4.3.0 --image git-sync:v4.3.0
