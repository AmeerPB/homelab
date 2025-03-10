## Grafana + Prometheus + Node Exporter

``` bash
touch docker-compose.yml
mkdir Prometheus
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

