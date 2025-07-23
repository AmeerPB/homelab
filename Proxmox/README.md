
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

# Attach the new disk to the vm as a scsi drive on the scsi controller
qm set 1001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-1001-disk-0

# Add cloud init drive
qm set 1001 --ide2 local-lvm:cloudinit

# Make the cloud init drive bootable and restrict BIOS to boot from disk only
qm set 1001 --boot c --bootdisk scsi0

# Add serial console
qm set 1001 --serial0 socket --vga serial0

# Add SSH Pub key and DNS server IP's in the cloud init console of the VM 1001

# Create template
qm template 1001

```
<br>

### 

### Issue : 1 

### No Guest Agent configured






