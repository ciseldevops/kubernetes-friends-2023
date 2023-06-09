Install CLI

```
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/XXXXX/.linkerd2/bin
linkerd version

```

Validate cluster and install linkerd

```
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
linkerd check

```

Metrics and Dashboard

```
kubectl apply -f linkerd/viz-install.yaml
linkerd check

```
Create ingress
```
cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: web-ingress-auth
  namespace: linkerd-viz
data:
  auth: YWRtaW46JGFwcjEkbjdDdTZnSGwkRTQ3b2dmN0NPOE5SWWpFakJPa1dNLgoK
---
# apiVersion: networking.k8s.io/v1beta1 # for k8s < v1.19
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: linkerd-viz
  annotations:
    nginx.ingress.kubernetes.io/upstream-vhost: $service_name.$namespace.svc.cluster.local:8084
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Origin "";
      proxy_hide_header l5d-remote-ip;
      proxy_hide_header l5d-server-id;      
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: web-ingress-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
  ingressClassName: nginx
  rules:
  - host: dashboard.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 8084
EOF
```

Mesh demo-app
```
kubectl get -n demo-app deployment demo-app -o yaml | linkerd inject - | kubectl apply -f -
```

Emoji Demo App
```
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -
kubectl -n emojivoto port-forward svc/web-svc 8080:80


Uninstall
```
linkerd viz uninstall | kubectl delete -f -
linkerd uninstall | kubectl delete -f -
```

Source : https://linkerd.io/2.13/getting-started/

