Create Grafana app in ArgoCD


Grafana Values in ArgoCD
```
ingress:
  enabled: true
  hosts:
    - grafanademo.example.com
persistence:
  type: pvc
  enabled: true
```

Récupération mot de passe par féfaut
```
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo
```
