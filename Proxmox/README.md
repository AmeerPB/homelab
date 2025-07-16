
# Steps to change the default SSL to a custom domain's SSL

## Back up the default Proxmox SSL files:
``` bash
mv /etc/pve/local/pveproxy-ssl.pem /etc/pve/local/pveproxy-ssl.pem.bak
mv /etc/pve/local/pveproxy-ssl.key /etc/pve/local/pveproxy-ssl.key.bak
```

## Copy the new certificates:
``` bash
cp /etc/letsencrypt/live/proxmox.yourdomain.com/fullchain.pem /etc/pve/local/pveproxy-ssl.pem
cp /etc/letsencrypt/live/proxmox.yourdomain.com/privkey.pem /etc/pve/local/pveproxy-ssl.key
```

## Set correct permissions:
``` bash
chmod 640 /etc/pve/local/pveproxy-ssl.*
```

## Restart Proxmox Web Interface
``` bash
systemctl restart pveproxy
```

<br>

# Steps to create a cloud-init vm template (with qemu guest agent)

``` bash
# Install libguestfs-tools so that we can install the qemu-guest-agent on to the downloaded image
apt install libguestfs-tools

# Install the qemu-guest-agent package
virt-customize -a debian-12-generic-amd64.qcow2 --install qemu-guest-agent

# Crete a new VM
qm create 1001 --memory 2048 --core 2 --name k8s-Master --net0 virtio,bridge=vmbr0

# Import the downloaded Debian disk to local storage 
qm disk import 1001 debian-12-generic-amd64.qcow2 local-lvm



```
<br>


