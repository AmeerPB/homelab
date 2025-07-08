# Use a slim Debian base image
FROM debian:latest

# Set environment variables for non-interactive install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl unzip gnupg lsb-release awscli git rsync gnupg software-properties-common wget \
    iproute2 iputils-ping net-tools telnet dnsutils vim && \
    rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
	gpg --dearmor | \
	tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
	apt update && \
	apt install terraform -y && \
	rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /workspace

# Default to bash shell
ENTRYPOINT ["/bin/bash"]
