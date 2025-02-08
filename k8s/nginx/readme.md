## Deploy NGINX Ingress Controller

**[Reference](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/)**


``` bash
helm pull oci://ghcr.io/nginx/charts/nginx-ingress --untar --version 2.0.0
cd nginx-ingress/

k create ns nginx-ingress
k apply -f crds -n nginx-ingress

helm install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress --version 2.0.0 -n nginx-ingress
```
``` bash
k get svc -n nginx-ingress
```

&nbsp;

## To deploy a nginx webserver with SSL certificate

### 1. Verify that the secret exists

``` bash
kubectl get secret <your-secret-name> -n <your-namespace>
```

If you haven’t created the secret, you can do it like this:

```bash
kubectl create secret tls my-tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n default  # Change namespace if needed
```  


### 2. configure the deployment and service

```nginx-deployment.yml```

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-server
  namespace: test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-server
  template:
    metadata:
      labels:
        app: nginx-server
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: test
spec:
  selector:
    app: nginx-server
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

### 3. Configure the Ingress

```nginx-ingress.yml```

```yml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: test
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - webapp1.machinesarehere.in
      secretName: machinesarehere-tls
  rules:
    - host: webapp1.machinesarehere.in
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

### 4. apply the files

``` bash
kubectl apply -f nginx-deployment.yml
kubectl apply -f nginx-ingress.yml
```

### 5. Verify deployment

```bash
kubectl get pods -n default
kubectl get svc -n default
kubectl get ingress -n default
```





&nbsp;

## Create an INGRESS to deploy NGINX with domain name

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: 
  name: web-app
spec:
  ingressClassName: nginx
  rules:
  - host: web-app.machinesarehere.in
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port: 
              number: 80
```              
``` bash
k apply -f nginx-ingress.yml -n test
k get ingress -n test
```







&nbsp;


## To deploy NGINX with metallb loadBalancer

nginx-deployment.yml

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: nginx-deployment
 labels:
   app: nginx
spec:
 replicas: 3
 selector:
   matchLabels:
     app: nginx
 template:
   metadata:
     labels:
       app: nginx
   spec:
     containers:
     - name: nginx
       image: nginx:1.14.2
       ports:
       - containerPort: 80
 strategy:
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 1

---

apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
  ```

``` bash
k apply -f nginx-deployment.yml -n test
```
