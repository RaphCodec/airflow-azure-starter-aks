# Overview

Welcome to the Airflow on Azure Kubernetes Service (AKS) Starter Guide!

This documentation provides a comprehensive guide for deploying and managing Apache Airflow on Azure using Kubernetes. It is designed for data engineers, platform/infra engineers, and teams looking to run Airflow in a secure, scalable, and production-ready environment on Azure.

## What You'll Find Here

- **Architecture:** Learn about the system design, components, and how they interact.
- **Prerequisites:** Tools and permissions required to get started.
- **Authentication & Authorization:** How access is managed using Azure AD groups and RBAC.
- **Glossary:** Definitions of key terms, Azure resources, and Airflow components.

## Why Use This Starter Kit?

- Provides a near production-ready baseline for Airflow on AKS
- Implements best practices for security, scalability, and maintainability
- Uses Azure-native services for identity, secrets, and storage
- Modular scripts and helpers for easy deployment and troubleshooting

## Quick Start

1. Review the [Prerequisites](Prerequisites.md) and install required tools.
2. Understand the [Architecture](Architecture.md) and components.
3. Set up Azure AD groups for admins and users as described in [Authentication & Authorization](Auth.md).
4. Follow the deployment scripts in the `airflow-aks/deploy-airflow/` directory.
5. Reference the [Glossary](../Glossary.md) for definitions as needed.

---

For detailed instructions, start with the next section: [Architecture](Architecture.md)

