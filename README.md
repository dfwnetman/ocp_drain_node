# OpenShift Drain Node Service
This service will ensure a node drains its pods, before shutting down.

## Installation
1. **Setup** - Copy the /etc/origin/master/admin.kubeconfig file from a master node.

2. **Install** Run the following comman to install 
ansible-playbook os-unsched-node.yml

## Notes
This playbook assumes the node type is included in the hostname (position 10-12). For example:
 master ('mas') node: ocpdevnodmas01
 infra ('inf') node: ocpdevnodinf01
 app ('app') node: ocpdevnodapp01

The playbook uses the node type to only install on infra & app nodes.


