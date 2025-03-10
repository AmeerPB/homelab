## Grafana + Prometheus + Node Exporter

``` bash
touch docker-compose.yml
mkdir Prometheus
```

## Install Node Exporter

[Git Reference](https://github.com/prometheus/node_exporter/releases)  

``` bash
LATEST_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name)
VERSION_ID=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name | cut -c2-)
wget https://github.com/prometheus/node_exporter/releases/download/$LATEST_VERSION/node_exporter-$VERSION_ID.linux-arm64.tar.gz
tar xzf node_exporter-$VERSION_ID.linux-arm64.tar.gz
mv node_exporter-$VERSION_ID.linux-arm64/node_exporter /usr/local/bin/
rm -rf node_exporter-$VERSION_ID.linux-arm64
rm node_exporter-$VERSION_ID.linux-arm64.tar.gz

useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

cat <<EOF >> /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
systemctl status node_exporter.service
```

```docker-compose.yml```   
``` yaml
services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    volumes:
      - ./Prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
    networks:
      - traefik-proxy
    labels:
      - "traefik.enable=false"


  grafana:
    image: grafana/grafana
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=12345678900
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - traefik-proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.entrypoints=http"
      - "traefik.http.routers.grafana.rule=Host(`grafana.machinesarehere.in`)"
      - "traefik.http.routers.grafana-secure.entrypoints=https"
      - "traefik.http.routers.grafana-secure.rule=Host(`grafana.machinesarehere.in`)"
      - "traefik.http.routers.grafana-secure.tls=true"
      - "traefik.http.routers.grafana-secure.tls.certresolver=cloudflare"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"

volumes:
  grafana-data:
    name: grafana-data
  prometheus-data:
    name: prometheus-data

networks:
  traefik-proxy:
    external: true
```

```Prometheus/prometheus.yml```   
``` yaml
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
          - localhost:9090

  - job_name: vps
    static_configs:
      - targets: ['192.168.50.10:9100']
```

