## Grafana installation via HELM

1. Go to **[Artifact Hub](https://artifacthub.io/)**
2. search for Grafana
3. Install Grafana
    ``` bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    helm install grafana grafana/grafana --version 8.9.0
    ```
4. Verify the Installation
    ```bash
    kubectl get all -n default
    ```
5. Take a backup of the service
    ``` bash
    kubectl get svc -n default | grep grafana
    kubectl get svc grafana -n default -o yaml > grafana-service-original.yml

    cat <<EOF | tee -a grafana-service.yml
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        meta.helm.sh/release-name: grafana
        meta.helm.sh/release-namespace: default
      labels:
        app.kubernetes.io/instance: grafana
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: grafana
        app.kubernetes.io/version: 11.5.1
        helm.sh/chart: grafana-8.9.0
      name: grafana
      namespace: default
    spec:
      ports:
      - name: service
        port: 3000
        protocol: TCP
        targetPort: 3000
      selector:
        app.kubernetes.io/instance: grafana
        app.kubernetes.io/name: grafana
      type: ClusterIP
    EOF
    ```
6. Delete the current grafana service and apply the new one
    ``` bash
    kubectl delete svc grafana -n default
    kubectl apply -f grafana-service.yml
    ```
7. Create a new Ingress for grafana
    ``` bash
    cat <<EOF | tee -a grafana-ingress.yml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: grafana-ingress
      namespace: default
      annotations:
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    spec:
      ingressClassName: nginx
      tls:
        - hosts:
            - grafana.machinesarehere.in
          secretName: machinesarehere-tls
      rules:
        - host: grafana.machinesarehere.in
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: grafana
                    port:
                      number: 3000
    EOF
    apply -f grafana-ingress.yml
    ```    
8. Verify the Installation
    ``` bash
    kubectl get all -n default
    kubectl get ing -n default
    ```