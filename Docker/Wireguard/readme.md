## Generate password

```bash
#Install htpasswd if not already done
apt update && apt install apache2-utils -y

#Generate passwd hash
htpasswd -bnBC 10 "" "YourSecurePassword" | tr -d ':\n'

#  Explanation:
#  -b → Use the password provided on the command line.
#  -n → Print the result to stdout (without saving to a file).
#  -B → Use bcrypt (stronger) instead of the default MD5.
#  -C 10 → Set bcrypt cost (higher is more secure, but slower).
#  "" → An empty username (since you only need the hash).
#  "YourSecurePassword" → Replace this with your actual password.
#  tr -d ':\n' → Removes unnecessary : and newline characters from output.
```

## Create a Docker network

``` bash
docker network create \
  --driver=bridge \
  --subnet=172.10.0.0/16 \
  traefik-proxy
```

## Create files and directories

``` bash
mkdir Traefik
cd Traefik
touch acme.json config.yml traefik.yml


```

```docker-compose.yml```

``` yaml
services:
  traefik:
    image: traefik
    container_name: traefik
    restart: unless-stopped
    command:
      #      - "--api.insecure=true"   # Optional: to access Traefik's dashboard
      - "--log.level=DEBUG"     # Set log level to DEBUG
      - "--accesslog=true"      # Enable access logs
    security_opt:
      - no-new-privileges:true
    networks:
       traefik-proxy:
    ports:
      - 80:80
      - 443:443
    environment:
      - CF_API_EMAIL=<email-address>
      - CF_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxx
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./Traefik/traefik.yml:/traefik.yml:ro
      - ./Traefik/acme.json:/acme.json
      - ./Traefik/config.yml:/config.yml:ro
      - ./Traefik/logs:/var/log/traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik.machinesarehere.in`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:xxxxxxxxxxxxxxxxxxxxxxxxxx"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`traefik.machinesarehere.in`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=machinesarehere.in"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.machinesarehere.in"
      - "traefik.http.routers.traefik-secure.service=api@internal"


services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    networks:
      traefik-proxy:
        ipv4_address: 172.10.0.3
    environment:
      TZ: "Europe/Berlin"
      FTLCONF_webserver_api_password: '<pi-hole gui password>'
      PIHOLE_DNS_: "1.1.1.1;8.8.8.8"
      DNSMASQ_LISTENING: "all"
      VIRTUAL_HOST: "pihole.machinesarehere.in"
    volumes:
      - ./pihole/etc-pihole:/etc/pihole
      - ./pihole/etc-dnsmasq:/etc/dnsmasq.d
    ports:
      - "127.0.0.1:53:53/tcp"
      - "127.0.0.1:53:53/udp"    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pihole.entrypoints=http"
      - "traefik.http.routers.pihole.rule=Host(`pihole.machinesarehere.in`)"
      - "traefik.http.middlewares.pihole-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.pihole-secure.entrypoints=https"
      - "traefik.http.routers.pihole-secure.rule=Host(`pihole.machinesarehere.in`)"
      - "traefik.http.routers.pihole-secure.tls=true"
      - "traefik.http.routers.pihole-secure.tls.certresolver=cloudflare"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"


services:
  wg-easy:
    environment:
      - WG_HOST=wg.machinesarehere.in
      - PASSWORD_HASH=<hash-obtained-via-htpasswd>
      - WG_ALLOWED=10.10.0.0/16
      - WG_DEFAULT_DNS=172.10.0.3 
    image: ghcr.io/wg-easy/wg-easy:nightly
    container_name: wg-easy
    volumes:
      - /home/debian/Docker/Wireguard:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    networks:
      traefik-proxy:  
        ipv4_address: 172.10.0.4
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wg.entrypoints=http"
      - "traefik.http.routers.wg.rule=Host(`wg.machinesarehere.in`)"
      - "traefik.http.routers.wg-secure.entrypoints=https"
      - "traefik.http.routers.wg-secure.rule=Host(`wg.machinesarehere.in`)"
      - "traefik.http.routers.wg-secure.tls=true"
      - "traefik.http.routers.wg-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.wg-secure.tls.domains[0].main=machinesarehere.in"
      - "traefik.http.routers.wg-secure.tls.domains[0].sans=*.machinesarehere.in"
      - "traefik.http.services.wg.loadbalancer.server.port=51821" 




networks:
  traefik-proxy:
    name: traefik-proxy  
    external: true
