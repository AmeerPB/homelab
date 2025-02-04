# kubeadm installation

#### Basic steps

1. install containerd on all nodes
2. install kubeadm on all nodes
3. initialise the master node
4. Once the master is initialised, prior to the worker joining, set up the POD n/w
5. Join worker nodes with master node


### Install and configure prerequisites

#### Enable IPv4 packet forwarding

https://kubernetes.io/docs/setup/production-environment/container-runtimes/#prerequisite-ipv4-forwarding-optional

``` bash

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.ipv4.ip_forward

```

### Installing a container runtime

#### Install containerd

https://docs.docker.com/engine/install/ubuntu/

``` bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

```

``` bash

sudo apt install -y containerd.io
systemctl status containerd

```

Goto the Cgroup drivers, 






