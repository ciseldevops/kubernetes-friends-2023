Pour déployer Traefik et Traefik Pilot sur un cluster SKS, vous pouvez suivre les étapes suivantes :

Ajouter le référentiel Helm de Traefik :

```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
```

Créer un namespace pour Traefik :
```
kubectl create namespace traefik
```

Installer Traefik avec Helm :
```
helm install traefik traefik/traefik \
  --namespace traefik
```

Vérifier que le déploiement de Traefik est terminé :

```
kubectl get pods -n traefik -w
```

Exposer le dashboard sur : http://127.0.0.1:9000/dashboard/
```
kubectl -n traefik port-forward $(kubectl -n traefik get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000 &
```

Créer un déploiement NGINX avec ingress Traefik
```
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /nginx
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
EOF
```
