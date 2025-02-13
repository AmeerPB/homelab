#!/usr/bin/env bash

echo -e "> \e[31m  _          _                    _           \e[0m"
echo -e "> \e[31m | | ___   _| |__   ___  __ _  __| |_ __ ___  \e[0m"
echo -e "> \e[31m | |/ / | | | '_ \ / _ \/ _` |/ _` | '_ ` _ \ \e[0m"
echo -e "> \e[31m |   <| |_| | |_) |  __/ (_| | (_| | | | | | |\e[0m"
echo -e "> \e[31m |_|\_\\__,_|_.__/ \___|\__,_|\__,_|_| |_| |_|\e[0m"



# Disable swap
sed -i '/^swap/s/^/#/' /etc/fstab
sudo swapoof -a
echo -e "> \e[32mSwap disabled\e[0m"


# Change the hostname with a FQDN
hostnamectl set-hostname $HOST_NAME
echo -e "> \e[32mChange the hostname to $HOST_NAME\e[0m"



# Update the package
sudo apt update && sudo apt upgrade -y
echo -e "> \e[32mPackages upgraded\e[0m"



# Install Container Runtime
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done



# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo -e "> \e[32mDocker GPG key added\e[0m"



# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo -e "> \e[32mInstalled Docker and Container.d\e[0m"




# Add local user to docker group
sudo usermod -aG docker $USER
echo -e "> \e[32mAdded local user to the docker group\e[0m"



# Enable kernel modules
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
echo -e "> \e[32mEnabled the kernel modules\e[0m"





# Configure the Cgroup driver
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

sudo cp -pr /etc/containerd/config.toml /etc/containerd/config.toml-original
sudo sed -i 's/^\(\s*\)SystemdCgroup = false/\1SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
echo -e "> \e[32mConfigured the Cgroup driver\e[0m"






# Install kubelet kubeadm and kubectl
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo -e "> \e[32mnstalled kubelet kubeadm and kubectl\e[0m"












