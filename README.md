# OpenShift Drain Node Service
This service will ensure a node drains its pods, before shutting down.

## Setup
This playbook is self-contained, and no longer uses the oc_serviceaccount & oc_adm_policy_user custom ansible modules.
1. **KUBECONFIG** - The playbook requires "oc client" access to the cluster, via an existing KUBECONFIG (such as the one used during the OCP4 install, `/home/<<myinstalluser>>/ocp4_install/auth/kubeconfig ocp4-drain-node.yml`).
2. **Utility/Helper Node** - This playbook requires ssh access to a node that contains the KUBECONFIG file (such as the utility/helper node used to install).
3. **Ansible hosts file** - This playbook requires the ansible hosts inventory file, hosts_ocp4_qc, to contain the `Utility/Helper Node` (such as `myhelpernode.ocp4.example.com`).


## Installation
1. **Install** - Run the following command to install:
```bash
ansible-playbook -i hosts_ocp4_qc -e kube_config=/home/user/ocp4_install/auth/kubeconfig ocp4-drain-node.yml
```



