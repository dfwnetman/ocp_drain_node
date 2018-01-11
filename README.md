# OpenShift Drain Node Service
This service will ensure a node drains its pods, before shutting down.

## Setup
This playbook uses the oc_serviceaccount & oc_adm_policy_user custom ansible roles available in the OpenShift installer.
1. **Install OpenShift utilities** - Install atomic-openshift-utils
`yum install atomic-openshift-utils`
2. **Configure ansible** - Configure ansible to use the custom ansible roles. Edit the /etc/ansible/ansible.cfg file, and set roles_path:
`roles_path = /etc/ansible/roles:/usr/share/ansible/openshift-ansible/roles`


## Installation
1. **Create service account** - Run playbook to create drain_node custom role and drain-node-sa service account
`ansible-playbook -l masters[0] os-unsched-node-sa.yml`

2. **Set ocp_url** - Set local ocp_url variable to the OpenShift Container Platform server URL. For example,  
`ocp_url=https://openshift.example.com`

3. **Set sa_token** - Set local sa_token variable to drain-node-sa service account's token
`sa_token=$(ansible masters -l masters[0] -a 'oc sa get-token -n openshift drain-node-sa'| egrep -v '\| SUCCESS \|')`

4. **Install** - Run the following comman to install 
`ansible-playbook -l nodes:\!masters -e sa_token=${sa_token} os-unsched-node.yml`



