# kubeadm installation

#### Basic steps

1. Create a (Debian 12) VM from the template and assign static IP (via netplan)
1. Disable swap on all the master/worker nodes
1. install containerd on all nodes
2. install kubeadm on all nodes
3. initialise the master node
4. Once the master is initialised, prior to the worker joining, set up the POD n/w
5. Join worker nodes with master node

> [!NOTE]
> 
> To install with the script, please set a proper FQDN for the hostname in the variable HOST_NAME first. Only then run the script. 



&nbsp;
[!NOTE]  
Method 1


## Assign static IP

Disable cloud-init's network configuration capabilities, create the following file 

``` bash
touch /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo "network: {config: disabled}" >> /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

Modify the ```eth0``` interface on the ```/etc/netplan/50-cloud-init.yaml``` file

change from 

``` yaml
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
            match:
                macaddress: bc:24:11:e8:31:01
            set-name: eth0
```            

to this

``` yaml
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: false
            addresses:
              - 192.168.1.200/24
            gateway4: 192.168.1.1
            nameservers:
              addresses:
                - 192.168.1.250
```

Then apply the configurations

``` bash 
netplan apply 
```


## Disable swap

``` bash
sudo swapoof -a
```

edit the file `/etc/fstab` and remove the swap entry


## Update the packages

``` bash
sudo apt update && sudo apt upgrade -y
```

## Install Container Runtime

**[Reference URL](https://docs.docker.com/engine/install/ubuntu/)**

``` bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

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

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Add local user to docker group

``` bash
sudo usermod -aG docker $USER
```
Exit and re-login.

## Enable the following kernel modules
**[Reference URL](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#prerequisite-ipv4-forwarding-optional)**

- [ ] IPv4 Packet forwarding
- [ ] Overlay
- [ ] br_netfilter

``` bash
sudo modprobe overlay
sudo modprobe br_netfilter
sudo modprobe dm_crypt

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward=1
EOF

sudo sysctl --system
```

## Configure the Cgroup driver

``` bash
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

sudo cp -pr /etc/containerd/config.toml /etc/containerd/config.toml-original
sudo sed -i 's/^\(\s*\)SystemdCgroup = false/\1SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl status containerd
sudo systemctl restart containerd
sudo systemctl status containerd
```

## Install kubelet kubeadm and kubectl
**[Reference URL](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)**

``` bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Change the hostname with a FQDN
``` bash
hostnamectl set-hostname <hostname in FQDN>
hostnamectl
```

## Initialise the kubeadm on Master/Controlplane node

``` bash
sudo kubeadm init \
  --pod-network-cidr 10.50.0.0/16 \
  --control-plane-endpoint "192.168.1.48:6443" \
  --upload-certs --v=5
```

## Install helm
**[Reference URL](https://helm.sh/docs/intro/install/)**

``` bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Install CNI

### Install cilium binary

**[Reference URL](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)**

``` bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

### Install cilium via HELM

with replacing kube-proxy

Updated (on 20thFeb2025)

> [!NOTE]
> The issue is that your original command used the incorrect cluster.poolIPv4PodCIDR setting, which is not a valid Helm value for configuring Cilium's cluster-pool mode. Instead, you need to use the correct IPAM settings (ipam.mode=cluster-pool and ipam.operator.clusterPoolIPv4PodCIDR)

Here is the corrected Helm install command that includes both the correct IPAM settings and your additional features like Hubble, Prometheus, and kube-proxy replacement:

``` bash
helm install cilium cilium/cilium --version 1.17.0 \
  --namespace kube-system \
  --set ipam.mode=cluster-pool \
  --set ipam.operator.clusterPoolIPv4PodCIDR="10.50.0.0/16" \
  --set ipam.operator.clusterPoolIPv4MaskSize=24 \
  --set kubeProxyReplacement=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  --set hubble.enabled=true \
  --set hubble.metrics.enableOpenMetrics=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2}" \
  --set hubble.metrics.httpV2.exemplars=true \
  --set hubble.metrics.httpV2.labelsContext="{source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction}"
```



> [!WARNING]
> 
> Old onme used to create the Cilium CNI, but still getting the 10.0.0.0/8 CIDR
> ``` python
> root@k8s:~/k8s/2/ArgoCD# k logs cilium-2sv4h -n kube-system | grep -i ipv4 | grep cluster-pool
> 
> Defaulted container "cilium-agent" out of: cilium-agent, config (init), mount-cgroup (init), apply-sysctl-overwrites (init), mount-bpf-fs (init), clean-cilium-state (init), install-cni-binaries (init)
> time="2025-02-19T12:01:46.505809749Z" level=info msg="  --cluster-pool-ipv4-cidr='10.0.0.0/8'" subsys=daemon
> time="2025-02-19T12:01:46.50581576Z" level=info msg="  --cluster-pool-ipv4-mask-size='24'" subsys=daemon
```

``` bash
helm install cilium cilium/cilium --version 1.17.0 \
  --namespace kube-system \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  --set hubble.enabled=true \
  --set hubble.metrics.enableOpenMetrics=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2}" \
  --set hubble.metrics.httpV2.exemplars=true \
  --set hubble.metrics.httpV2.labelsContext="{source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction}" \
  --set cluster.poolIPv4PodCIDR="10.50.0.0/16" \
  --set kubeProxyReplacement=true
```  

without replacing kube-proxy

``` bash
helm install cilium cilium/cilium --version 1.17.0 \
  --namespace kube-system \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  --set hubble.enabled=true \
  --set hubble.metrics.enableOpenMetrics=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
```

## Add CSI for volume persistence





&nbsp;
   
> [!WARNING]  
> Method 2
> 
> 
> ## Refer:
> 
> https://docs.cilium.io/en/latest/network/kubernetes/kubeproxy-free/
> 
> ## Disable swap
> 
> ``` bash
> sudo swapoof -a
> ```
> 
> edit the file `/etc/fstab` and remove the swap entry
> 
> 
> ## Install and configure prerequisites
> 
> ### Enable IPv4 packet forwarding
> 
> https://kubernetes.io/docs/setup/production-environment/container-runtimes/#prerequisite-ipv4-forwarding-optional
> 
> ``` bash
> # sysctl params required by setup, params persist across reboots
> cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.ipv4.ip_forward = 1
> EOF
> 
> # Apply sysctl params without reboot
> sudo sysctl --system
> ```
>    
> Verify that net.ipv4.ip_forward is set to 1 with:   
> ``` bash
> sysctl net.ipv4.ip_forward
> ```
>    
> 
> 
> ## Installing a container runtime
> 
> ### Install containerd
> 
> https://docs.docker.com/engine/install/ubuntu/
> 
> ``` bash
> # Add Docker's official GPG key:
> sudo apt-get update
> sudo apt-get install ca-certificates curl
> sudo install -m 0755 -d /etc/apt/keyrings
> sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
> sudo chmod a+r /etc/apt/keyrings/docker.asc
> 
> # Add the repository to Apt sources:
> echo \
>   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
>   $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
>   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
> sudo apt-get update
> ```
> 
> ``` bash
> sudo apt install -y containerd.io
> sudo systemctl status containerd
> 
> ```
> 
> Goto the Cgroup drivers, set `systemd` as Cgroup driver
> 
> https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver
> https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
> 
> Remove all the lines in the file /etc/containerd/config.toml and add the following snippets 
> 
> ``` bash
> [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
>   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
>     SystemdCgroup = true
> ```
> 
> Restart the containerd service
> 
> ``` bash
> sudo systemctl restart containerd
> ```
> 
> ## Installing kubeadm, kubelet and kubectl
> 
> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
> 
> ``` bash
> sudo apt-get update
> # apt-transport-https may be a dummy package; if so, you can skip that package
> sudo apt-get install -y apt-transport-https ca-certificates curl gpg
> 
> # If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
> # sudo mkdir -p -m 755 /etc/apt/keyrings
> curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
> ```   
>    
> ``` bash
> echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
> ```   
>    
> ``` bash
> sudo apt-get update
> sudo apt-get install -y kubelet kubeadm kubectl
> sudo apt-mark hold kubelet kubeadm kubectl
> ```   
> 
> 
> ## Initialise the master
> 
> ``` bash
> kubeadm init \
>   --apiserver-advertise-address=192.168.1.48 \
>   --pod-network-cidr=10.50.0.0/16 \
>   --skip-phases=addon/kube-proxy \
>   --control-plane-endpoint 192.168.1.48
> ```
> 
> 
> ## Install POD network (only on the Master node)
> 
> https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
> 
> ``` bash
> CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
> CLI_ARCH=amd64
> if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
> curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
> sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
> sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
> rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
> ```
> 
> ### Install cilium
> 
> ``` bash
> cilium install --version 1.16.6
> ```
> 
> 
> 
> ### HELM installation
> 
> https://helm.sh/docs/intro/install/
> 
> 
> ``` bash
> curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
> chmod 700 get_helm.sh
> ./get_helm.sh
> ```
> 
> ### Install cilium binary
> 
> https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
> 
> 
> ```
> CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
> CLI_ARCH=amd64
> if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
> curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
> sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
> sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
> rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
> ```
> 
> ### Deploy cilium in K8s via HELM 
> 
> ```
> helm repo add cilium https://helm.cilium.io/
> 
> helm install cilium cilium/cilium --namespace kube-system \
> --set ipam.mode=kubernetes \
> --set kubeProxyReplacement=true \
> --set hubble.relay.enabled=true \
> --set hubble.ui.enabled=true
> ```
> 
>    
> ### Based on Cilium HELMinstall [doc](https://docs.cilium.io/en/latest/network/kubernetes/kubeproxy-free/)
> 
> Download the Cilium release tarball and change to the kubernetes install directory   
> ``` bash
> curl -LO https://github.com/cilium/cilium/archive/main.tar.gz
> tar xzf main.tar.gz
> cd cilium-main/install/kubernetes
> ```
> 
> ``` bash
> helm install cilium ./cilium \
>     --namespace kube-system \
>     --set kubeProxyReplacement=true \
>     --set k8sServiceHost=192.168.1.48 \
>     --set k8sServicePort=6443
> ```
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
