## Setup instructions for installing Pi-Hole and 
## setting SSL with NGINX reverse-proxy


### Steps
1. Install pi-hole
2. Change web UI port
3. Install Nginx
4. Generate the SSL for your domain
4. Configure pihole.conf for Nginx


### Install Pi-Hole

[Reference](https://docs.pi-hole.net/main/basic-install/)

``` bash
curl -sSL https://install.pi-hole.net | bash
```


### Change web UI port
``` bash
# Disable pihole-FTL.service
systemctl stop pihole-FTL.service

# Change web UI port in /etc/pihole/pihole.toml
port = "8080o,[::]:8080o" 

# Enable pihole-FTL.service
systemctl start pihole-FTL.service && systemctl status pihole-FTL.service
```
### Install NGINX

``` bash
apt update && apt install nginx -y
```

### Generate SSL for domain with certbot

``` bash
sudo certbot certonly --manual --preferred-challenges=dns -d <domain-name>
```

### Add and configure pihole.conf in /etc/nginx/sites-available/

``` bash
# Create the file
touch /etc/nginx/sites-available/pihole.conf

# Add components of pihole.conf

# Create a symlink to sites-enabled
ln -s /etc/nginx/sites-available/pihole.conf /etc/nginx/sites-enabled/

# Verify whether the new config
nginx -t

# Reload nginx svc
systemctl reload nginx
```


