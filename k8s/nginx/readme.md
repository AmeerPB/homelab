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
