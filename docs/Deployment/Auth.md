# Authentication & Authorization

This setup is designed to use two Azure Active Directory (AAD) groups:

- **Admin Group:** Members have full administrative access to the AKS cluster and Airflow deployment.
- **Non-Admin Group:** Members have limited access, suitable for regular users or data engineers.

## Why Two Groups?

Separating admin and non-admin users helps enforce the principle of least privilege, reducing the risk of accidental or malicious changes to critical infrastructure. Admins can manage resources, while non-admins can use Airflow without elevated permissions.

This also simplifies onboarding and ongoing access management. Admins are responsible only for controlling who is an admin via Azure AD group membership. All non-admin user permissions are managed entirely within Airflow’s own RBAC system.

By doing this, we avoid mapping individual Airflow roles to Azure App Registrations or Entra ID groups. New Airflow roles can be created and adjusted directly in Airflow without requiring Azure-side changes, making RBAC simpler to manage and faster to evolve.

## How it Works

- Azure RBAC and Kubernetes RBAC are configured to map these groups to appropriate roles.
- Workload Identity and Key Vault access policies are set to restrict sensitive operations to admins.
- Airflow UI access can be further restricted based on group membership.

> **Note:** You must create these groups in Azure Entra ID and assign users before deploying.

---

See the [Prerequisites](Prerequisites.md) section next to review the tools you will need to use this repository.
