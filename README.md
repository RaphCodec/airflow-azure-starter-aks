
# airflow-azure-starter-aks

This repository provides a near production-ready starter kit for deploying Apache Airflow on Azure Kubernetes Service (AKS) using best practices for security, scalability, and maintainability.

## What's Included

- Scripts for deploying Airflow and all required Azure resources
- Helpers for Azure permissions and troubleshooting
- Helm chart configuration for Airflow
- Example architecture diagrams
- Documentation powered by MkDocs

## Folder Structure

```
airflow-aks/
	az-helpers/         # Azure permission helper scripts
	deploy-airflow/     # Airflow deployment scripts and configs
	diagrams/           # Architecture diagrams
docs/                 # Project documentation (see GH Pages)
mkdocs.yml            # MkDocs configuration
README.md             # Project overview (this file)
```

## Documentation

For full documentation and setup instructions, visit the [project documentation site](https://raphcodec.github.io/airflow-azure-starter-aks/).
