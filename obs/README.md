Grafana app in ArgoCD


Grafana Values in ArgoCD
ingress:
  enabled: true
  hosts:
    - grafanademo.example.com
persistence:
  type: pvc
  enabled: true

kubectl get secret --namespace moinitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl get secret --namespace moinitoring grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo
