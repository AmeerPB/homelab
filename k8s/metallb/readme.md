**[Reference](https://metallb.io/installation/)**

### Pre-requisite
``` bash
kubectl edit configmap -n kube-system kube-proxy
```

change ```strictARP: false``` to ```strictARP: true```

``` bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```

``` bash
k get po -n metallb-system
k api-resources | grep metallb
```

IPAddressPool.yml

``` yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.200-192.168.1.230  
  ```

``` bash
k apply -f IP-pool.yml -n metallb-system
k get IPAddressPool -n metallb-system
```

l2-advertisement.yml

```yml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: homelab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```
``` bash
k apply -f l2-advertisement.yml
k get l2Advertisement -n metallb-system
```
