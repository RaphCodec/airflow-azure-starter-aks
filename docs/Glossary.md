# Glossary

## Apache Airflow

!!! note "Airflow Arichitecture Version"

    These definitions are based on the Apache Airflow 3.x architecture.  For more details visit the official [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/overview.html) page.

**Apache Airflow (Airflow):** Open-source platform to programmatically author, schedule, and monitor workflows using Python.

**DAG (Directed Acyclic Graph):** A collection of tasks organized with dependencies that defines a workflow in Airflow.

**DAG Bundle:** A versioned, immutable package of DAG code and related resources (for example, Python files, SQL, templates). In Airflow 3, DAGs are distributed to components (scheduler, DAG processor, workers) as bundles rather than being read directly from a shared filesystem.

**DAG Processor:** Dedicated Airflow component responsible for parsing DAG bundles, validating DAG definitions, and serializing DAGs into the metadata database. This decouples DAG parsing from scheduling and execution.

**Airflow Scheduler:** Determines when DAG runs and task instances should be created based on schedules, dependencies, and state stored in the metadata database.

**Airflow Worker:** Executes task instances (for example via Celery or Kubernetes executors) using the DAG code provided through DAG bundles.

**Airflow API Server:** Stateless service that exposes Airflow’s REST API. In Airflow 3, it is a first-class component separated from the web UI and scheduler, enabling scalable and secure API access.

**Airflow Webserver (UI):** Web-based user interface for monitoring DAGs, task runs, and system state. It relies on the API server rather than directly accessing internal components.

**Airflow Metadata Database:** Central database that stores DAG metadata, task state, schedules, connections, variables, and serialized DAGs.

**Celery:** Distributed task queue commonly used by Airflow’s Celery Executor to run tasks in parallel across multiple workers.


## Azure

**AKS (Azure Kubernetes Service):** Managed Kubernetes service for running containerized applications.

**Azure Key Vault:** Securely stores secrets, keys, and certificates.

**Azure Container Registry (ACR):** Private Docker registry for building, storing, and managing container images.

**Azure Flexible Server for PostgreSQL:** Managed PostgreSQL database service.

**Azure Redis Cache:** In-memory data store used as a message broker for Celery.

**Azure Data Lake Storage Gen2 (ADLS Gen2):** Scalable storage for big data analytics.

**Workload Identity:** Azure feature for assigning managed identities to Kubernetes pods.


## CLI Tools

**CLI:** Command Line Interface

**Helm:** Kubernetes package manager for deploying applications.

**kubectl:** Command-line tool for interacting with Kubernetes clusters.

**Azure CLI:** Command-line tool for managing Azure resources.

**git:** Version control system for tracking changes in source code.

**Docker:** Platform for developing, shipping, and running applications in containers.

