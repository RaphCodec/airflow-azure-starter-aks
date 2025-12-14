# Prerequisites

!!! note "Virtual Machine Installation"

    These tools may be installed on an Azure VM if you would like to use a managed identity to provision resources and install Airflow.

Before using this repository, ensure you have the following tools installed:

- **kubectl** ([Install Guide](https://kubernetes.io/docs/tasks/tools/))
- **Helm** ([Install Guide](https://helm.sh/docs/intro/install/))
- **Azure CLI** ([Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Docker** ([Install Guide](https://docs.docker.com/get-docker/))
- **git** ([Install Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))

You will also need:
- Access to an Azure subscription with permissions to create resources
- Sufficient quota for AKS, Key Vault, ACR, PostgreSQL, Redis, and Storage

> **Tip:** Make sure you are logged in to Azure CLI and have the correct subscription selected before running deployment scripts.