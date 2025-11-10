# Airflow Demo

## Description
This Airflow deployment is intended to be for demonstration purposes only.  There isn't any SSO or produciton grade meta database inlcuded in this. 


## Prerquisites
- An Azure VM with a managed identity
- Ansible
- kubectl
- helm


## Steps
1. Create a vars.yml file based on the vars.example.yml file in the azure folder.
2. Create a python vitual environment and install the requirements.
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
3. Run the Ansible playbook to set up AKS and ACR.
```bash
ansible-playbook playbook.yml
```

4. Create a .env file with your repsecitve values based on the .env.example file in the airflow-helm folder. Make sure that the ACR environment variable is not the entire URL.  See the example and the airflow-values.yaml for reference.
5. make the install-airflow.sh file executable
```bash
chmod +x ./install-airflow.sh
```
6. Run the install airflow bash script to install Airflow with helm.
 **Note that the account running this needs to have permission to attach the ACR to AKS.  If it doesn't have that permission then the last step in the playbook will fail.  If you do not want to attach the ACR then use a managed identity to allow AKS to pull images from ACR.**

7. Access the Airflow UI.  If trying to access from the Azure VM you need to forward the VM's port to your localmachine.
```bash
ssh -L 8080:localhost:8080 azureuser@<VM_PUBLIC_IP>
```

Alternatively you can run the below commands on your local machine and then navigate to localhost:8080.

```bash
az aks get-credentials --resource-group $AKS_AIRFLOW_RESOURCE_GROUP --name $AKS_AIRFLOW_CLUSTER_NAME --overwrite-existing

kubectl port-forward svc/airflow-api-server 8080:8080 -n $AKS_AIRFLOW_NAMESPACE
```

