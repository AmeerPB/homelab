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