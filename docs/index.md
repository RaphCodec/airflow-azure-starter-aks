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

    airflow-aks/
        az-helpers/
            ... Files to help if there are azure permission issues
        deploy-airflow/
            ... Airflow deployment bash scripts
        diagrams/
            ... Arichitecture diagrams
    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.
