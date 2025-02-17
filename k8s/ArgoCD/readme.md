# ArgoCD installation 

## With manifest file

**[Reference](https://argo-cd.readthedocs.io/en/stable/getting_started/)**

``` bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Edit the configMap to disable TLS

**[Reference](https://argo-cd.readthedocs.io/en/latest/operator-manual/ingress/#option-2-ssl-termination-at-ingress-controller)**

```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

kubectl rollout restart deployment argocd-server -n argocd
```


## Add HTTP and gRPC argocd-Ingress

```bash

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-http-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd.machinesarehere.in
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
  tls:
    - hosts:
        - argocd.machinesarehere.in
      secretName: machinesarehere-tls
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-grpc-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd-grpc.machinesarehere.in
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 443
  tls:
    - hosts:
        - argocd-grpc.machinesarehere.in
      secretName: machinesarehere-tls
EOF
```      

## Get the Admin credential from the secret

The initial password for the admin account is auto-generated and stored as clear text in the field password in a secret named argocd-initial-admin-secret in your Argo CD installation namespace. 

``` bash
kubectl get secret -n argocd argocd-initial-admin-secret -o yaml
```

echo the ```data.password``` and decode from base64 will printout the admin password.


