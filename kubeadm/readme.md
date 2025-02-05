# kubeadm installation

#### Basic steps

1. Disable swap on all the master/worker nodes
1. install containerd on all nodes
2. install kubeadm on all nodes
3. initialise the master node
4. Once the master is initialised, prior to the worker joining, set up the POD n/w
5. Join worker nodes with master node

#### Refer:

https://docs.cilium.io/en/latest/network/kubernetes/kubeproxy-free/

### Disable swap

``` bash
sudo swapoof -a
```

edit the file `/etc/fstab` and remove the swap entry


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
```
   
Verify that net.ipv4.ip_forward is set to 1 with:   
``` bash
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
sudo systemctl status containerd

```

Goto the Cgroup drivers, set `systemd` as Cgroup driver

https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd

Remove all the lines in the file /etc/containerd/config.toml and add the following snippets 

``` bash
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

Restart the containerd service

``` bash
sudo systemctl restart containerd
```

### Installing kubeadm, kubelet and kubectl

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

``` bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```   
   
``` bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```   
   
``` bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```   


### Initialise the master

``` bash
kubeadm init \
  --apiserver-advertise-address=192.168.1.48 \
  --pod-network-cidr=10.50.0.0/16 \
  --skip-phases=addon/kube-proxy \
  --control-plane-endpoint 192.168.1.48
```


### Install POD network (only on the Master node)

https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/

``` bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

Install cilium

``` bash
cilium install --version 1.16.6
```



#### HELM installation

https://helm.sh/docs/intro/install/


``` bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

#### Install cilium binary

https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/


```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

#### Deploy cilium in K8s via HELM 

```
helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --namespace kube-system \
--set ipam.mode=kubernetes \
--set kubeProxyReplacement=true \
--set hubble.relay.enabled=true \
--set hubble.ui.enabled=true
```

   
#### Based on Cilium HELMinstall [doc](https://docs.cilium.io/en/latest/network/kubernetes/kubeproxy-free/)

Download the Cilium release tarball and change to the kubernetes install directory   
``` bash
curl -LO https://github.com/cilium/cilium/archive/main.tar.gz
tar xzf main.tar.gz
cd cilium-main/install/kubernetes
```

``` bash
helm install cilium ./cilium \
    --namespace kube-system \
    --set kubeProxyReplacement=true \
    --set k8sServiceHost=192.168.1.48 \
    --set k8sServicePort=6443
```















