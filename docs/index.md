# Airflow on Azure Kubernetes Service Starter Guide

## Description
This project is intended to project developers and teams with a near production-ready starting point with which to deploy [Apache Airflow](https://airflow.apache.org/) on [Azure Kubernetes Service](https://azure.microsoft.com/en-us/products/kubernetes-service).  

## Who this is for
- Data engineers
- Platform / infra engineers
- Teams running Airflow in Azure

## What this repo includes
- AKS
- Airflow via Helm
- Azure Workload Identity

## Project layout

```
airflow-aks/
  az-helpers/         # Azure permission helper scripts
  deploy-airflow/     # Airflow deployment scripts and configs
  diagrams/           # Architecture diagrams
docs/                 # Project documentation (see GH Pages)
mkdocs.yml            # MkDocs configuration
README.md             # Project overview (this file)
```
