## Deploy Longhorn for CSI

**[Installation Requirements](https://longhorn.io/docs/1.8.0/deploy/install/#installation-requirements)**

**[This script](https://longhorn.io/docs/1.8.0/deploy/install/#using-the-environment-check-script)** can be used to check the Longhorn environment for potential issues.

sample o/p

``` python
root@k8s:~/homelab/k8s/Longhorn# ./environment_check.sh 
[INFO]  Required dependencies 'kubectl jq mktemp sort printf' are installed.
[INFO]  All nodes have unique hostnames.
[INFO]  Waiting for longhorn-environment-check pods to become ready (0/2)...
[INFO]  Waiting for longhorn-environment-check pods to become ready (0/2)...
[INFO]  Waiting for longhorn-environment-check pods to become ready (0/2)...
[INFO]  All longhorn-environment-check pods are ready (2/2).
[INFO]  MountPropagation is enabled
[INFO]  Checking kernel release...
[INFO]  Checking iscsid...
[ERROR] kernel module iscsi_tcp is not enabled on worker1.machinesarehere.in
[ERROR] kernel module iscsi_tcp is not enabled on worker2.machinesarehere.in
[INFO]  Checking multipathd...
[WARN]  multipathd is running on worker1.machinesarehere.in known to have a breakage that affects Longhorn.  See description and solution at https://longhorn.io/kb/troubleshooting-volume-with-multipath
[WARN]  multipathd is running on worker2.machinesarehere.in known to have a breakage that affects Longhorn.  See description and solution at https://longhorn.io/kb/troubleshooting-volume-with-multipath
[INFO]  Checking packages...
[ERROR] nfs-common is not found in worker1.machinesarehere.in.
[ERROR] nfs-common is not found in worker2.machinesarehere.in.
[INFO]  Checking nfs client...
[INFO]  Cleaning up longhorn-environment-check pods...
[INFO]  Cleanup completed.
```

### 1. Install the missing packages
```bash
sudo apt install open-iscsi -y
sudo apt install nfs-common -y

#Load the module manually
sudo lsmod | grep iscsi_tcp
sudo modprobe iscsi_tcp

#Ensure the module loads on reboot
echo "iscsi_tcp" | sudo tee /etc/modules-load.d/iscsi.conf

#Enable the service
sudo systemctl enable iscsid.service
```

### 2. Install LongHorn

**[Reference](https://longhorn.io/docs/1.8.0/deploy/install/install-with-helm/)**

with HELM

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.8.0
kubectl -n longhorn-system get pod
```
&nbsp;




## To access the Longhorn UI with domain name + SSL

1. check the service
2. Check the ingress
3. Take backup of ingress and service
4. Delete the service and Ingress
5. Create a new service and Ingress
6. Apply the service and Ingress
7. Check the status of Service and Ingress


Check the service and Ingress

```bash
kubectl get svc,ingress -n longhorn-system
```

Take backup of Service and Ingress

```bash
kubectl get ing longhorn-frontend-ingress -n longhorn-system -o yaml > longhorn-frontend-ingress-original.yml

kubectl get svc longhorn-frontend -n longhorn-system -o yaml > longhorn-frontend-service-original.yml
```

Delete Service and Ingress

```bash
kubectl delete svc longhorn-frontend -n longhorn-system
kubectl delete ing longhorn-frontend-ingress -n longhorn-system
```

Create a new service file ```longhorn-frontend-service-2.yml```

```yml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: longhorn-ui
  name: longhorn-frontend
  namespace: longhorn-system
spec:
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 8000
    name: longhorn-frontend
  selector:
    app: longhorn-ui
```

Create a new Ingress file ```longhorn-frontend-ingress-2.yml```
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: longhorn-frontend-ingress
  namespace: longhorn-system
spec:
  ingressClassName: nginx
  rules:
  - host: longhorn.machinesarehere.in
    http:
      paths:
      - backend:
          service:
            name: longhorn-frontend
            port:
              number: 8000
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - longhorn.machinesarehere.in
    secretName: machinesarehere-tls
```

Apply the Service and Ingress files
``` bash
k apply -f longhorn-frontend-service-2.yml
k apply -f longhorn-frontend-ingress-2.yml
```

Check the status of Service and Ingress

```bash
kubectl get svc,ingress -n longhorn-system
```

Check the status of the UI Pod's
```bash
kubectl get po -n longhorn-system | grep ui
```






