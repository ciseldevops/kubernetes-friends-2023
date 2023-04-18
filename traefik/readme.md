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

