# airflow-azure-starter-aks

## Assumptions/Requirements
- An Azure VM with a Managed Identity

## Installing Ansible on an Azure VM

1. Create a python venv
```bash
python3 -m venv ansible-venv
source ansible-venv/bin/activate
```
2. Install ansible-core and Azure Collection
```bash
pip install ansible-core==2.18.6
ansible-galaxy collection install azure.azcollection
```
3. Install Additional Azure Collection python dependencies. These need to be installed as specified below because the current requirements.txt file that comes with the collection is out of date, as of writing this.
```bash
pip install azure-cli==2.75.0 msrestazure msgraph-sdk azure-mgmt-resourcehealth
```
```bash
pip install -r https://raw.githubusercontent.com/ansible-collections/azure/refs/heads/dev/requirements.txt
```
4. Verify that ansible is working by running the list-azure-vms.yml playbook.  You may additionally run the vm creation and deletion playbooks in the ansible-verifications/vm-management folder if you'd like to make sure that your Managed Identity can create resource in your desired resource group.
```bash
ansible-playbook list-azure-vms.yml
```

