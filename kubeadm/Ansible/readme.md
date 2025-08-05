## Ansible playbook to install and setup kubeadm both in Master and Worker Nodes

## Playbook run order

- kubeadm-install.yml
- kubeadm-init.yml
- extract-join-commands.yml
- join-cluster.yml
- deploy-cilium.yml