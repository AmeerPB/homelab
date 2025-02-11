## Prometheus installation via HELM


1. Go to https://artifacthub.io/
2. search for Prometheus
3. Install Prometheus
    ``` bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
    
    helm repo update

    helm install prometheus prometheus-community/prometheus --version 27.3.0
    ```
4. Verify the Installation
    ``` bash
    kubectl get all -n default ```
5. Take a backup of the service
    ``` bash
    kubectl get svc -n default | grep prometheus
    kubectl get svc prometheus-server -n default -o yaml > prometheus-server-service-original.yml

    cat <<EOF | tee -a prometheus-server-service.yml
    apiVersion: v1
    kind: Service
    metadata:
    annotations:
        meta.helm.sh/release-name: prometheus
        meta.helm.sh/release-namespace: default
    labels:
        app.kubernetes.io/component: server
        app.kubernetes.io/instance: prometheus
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: prometheus
        app.kubernetes.io/part-of: prometheus
        app.kubernetes.io/version: v3.1.0
        helm.sh/chart: prometheus-27.3.0
    name: prometheus-server
    namespace: default
    spec:
    ports:
    - name: http
        port: 9090
        protocol: TCP
        targetPort: 9090
    selector:
        app.kubernetes.io/component: server
        app.kubernetes.io/instance: prometheus
        app.kubernetes.io/name: prometheus
    type: ClusterIP
    EOF
    ```
6. Delete the current prometheus service and apply the new one
    ``` bash
    kubectl delete svc prometheus-server -n default
    kubectl apply -f prometheus-server-service.yml
    ```
7. Create a new Ingress for prometheus
    ``` bash
    cat <<EOL | tee -a prometheus-server.ingress.yml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    annotations:
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    name: prometheus-server-ingress
    namespace: default
    spec:
    ingressClassName: nginx
    rules:
    - host: prometheus.machinesarehere.in
        http:
        paths:
        - backend:
            service:
                name: prometheus-server
                port:
                number: 9090
            path: /
            pathType: Prefix
    tls:
    - hosts:
        - prometheus.machinesarehere.in
        secretName: machinesarehere-tls
    EOL

    apply -f prometheus-server.ingress.yml
    ```    
8. Verify the Installation
    ``` bash
    kubectl get all -n default
    kubectl get ing -n default
    ```

