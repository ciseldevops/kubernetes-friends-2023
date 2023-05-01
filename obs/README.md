Create App in ArgoCD
```
Name : grafana
Repo URL :  https://grafana.github.io/helm-charts/
Chart : Grafana
Version : 6.54.0
```
Add in the helm values
```
ingress:
  enabled: true
  ingressClassName: nginx
  hosts:
    - grafanademo.example.com
persistence:
  type: pvc
  enabled: true
adminUser: admin
adminPassword: demo
```

Some extra commands if necessary
```
kubectl -n monitoring patch ingress grafana -p '{"spec":{"ingressClassName":"nginx"}}'
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo
```

Prometheus deployment
```
kubectl apply -f kubernetes-friends-2023/obs/prometheus.yaml
```
