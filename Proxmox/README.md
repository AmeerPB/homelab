
# Steps to change the default SSL to a custom domain's SSL

### Back up the default Proxmox SSL files:
``` bash
mv /etc/pve/local/pveproxy-ssl.pem /etc/pve/local/pveproxy-ssl.pem.bak
mv /etc/pve/local/pveproxy-ssl.key /etc/pve/local/pveproxy-ssl.key.bak
```

### Copy the new certificates:
``` bash
cp /etc/letsencrypt/live/proxmox.yourdomain.com/fullchain.pem /etc/pve/local/pveproxy-ssl.pem
cp /etc/letsencrypt/live/proxmox.yourdomain.com/privkey.pem /etc/pve/local/pveproxy-ssl.key
```

### Set correct permissions:
``` bash
chmod 640 /etc/pve/local/pveproxy-ssl.*
```

### Restart Proxmox Web Interface
``` bash
systemctl restart pveproxy
```

