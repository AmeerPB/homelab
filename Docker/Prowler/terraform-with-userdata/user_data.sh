#!/usr/bin/env bash
set -e
 
# Update and install required packages
apt-get update -y
apt-get install -y git rsync wget curl ca-certificates gnupg lsb-release
 
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker packages
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add ubuntu user to docker group
usermod -aG docker ubuntu
 
# Setup Prowler directory
mkdir -p /home/ubuntu/prowler
chown ubuntu:ubuntu /home/ubuntu/prowler
 
# Download Prowler files
wget -O /home/ubuntu/prowler/docker-compose.yml https://raw.githubusercontent.com/prowler-cloud/prowler/refs/heads/master/docker-compose.yml
wget -O /home/ubuntu/prowler/.env https://raw.githubusercontent.com/prowler-cloud/prowler/refs/heads/master/.env
chown ubuntu:ubuntu /home/ubuntu/prowler/docker-compose.yml /home/ubuntu/prowler/.env
 
# Start Prowler docker compose as ubuntu user
sudo -u ubuntu bash -c 'cd /home/ubuntu/prowler && docker compose up -d'

 

 