Add Helm chart repo
```
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

Install longhorn in longhorn-system namespace
```
kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system \
  --set persistence.defaultClass=true \
  --set persistence.defaultClassReplicaCount=2 \
  --set ui.ingress.enabled=true \
  --set ui.ingress.hosts[0].host=longhorn.example.com \
  --set ui.ingress.hosts[0].paths[0]=/
  ```
