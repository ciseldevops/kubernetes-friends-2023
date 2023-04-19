
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
```
Create new application
Name : obs
Create Namespace : True
Repository : https://prometheus-community.github.io/helm-charts
Chart : kube-prometheus-stack
Namespace : obs
grafana.ingress.enabled : True
grafana.adminPassword : demo
```

Configure the ingress to use the nginx class
```
kubectl -n obs patch ingress obs-grafana -p '{"spec":{"ingressClassName":"nginx"}}'
```