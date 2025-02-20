# Setup cert-manager

## Install with HELM

**[Reference](https://cert-manager.io/docs/installation/helm/)**

``` bash
helm repo add jetstack https://charts.jetstack.io --force-update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true
```  


## Create a secret with the CloudFlare API key

![Reference](Images/cloudflare_API_Key.png)

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-key: "<YOUR_CLOUDFLARE_API_KEY>"
```  

## Create a cluster Issuer

``` yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cloudflare-clusterissuer
spec:
  acme:
    email: cert@xsec.in
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cloudflare-clusterissuer-account-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-key-secret
              key: api-key
```              

## Create a certificate

``` yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: machinesarehere-tls
  namespace: production
spec:
  secretName: machinesarehere-tls-secret
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - machinesarehere.in
    - "*.machinesarehere.in"
```
verify the certificate generation

``` bash
kubectl get certificate -n dev
kubectl describe certificate machinesarehere-tls -n dev
```

Describe the ```certificaterequest``` object to see the actual status whether it is issued or not.

``` bash
kubectl get certificaterequest -n dev
kubectl describe certificaterequest machinesarehere-tls-1 -n dev
```