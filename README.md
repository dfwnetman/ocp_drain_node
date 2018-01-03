# OpenShift Drain Node Service
This service will ensure a node drains its pods, before shutting down.

## Installation
1. **Setup** - Copy the /etc/origin/master/admin.kubeconfig file from a master node to the current working directory of where the os-unsched-node.yml resides.

2. **Install** Run the following comman to install 
`ansible-playbook -l nodes:\!masters os-unsched-node.yml`


The playbook uses the node type to only install on infra & app nodes.


