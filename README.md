# kubernetes-friends-2023
Fribourg Linux Seminar - Kubernetes Friends



# Fil conducteur


## Terraform et plus généralement l'IaC (Maitriser le Déploiement de ressources Infra)
### Deploy SKS cluster on Kubernetes using terraform

Access setup
```
export EXOSCALE_API_KEY=...
export EXOSCALE_API_SECRET=...
```

SKS deployment
```
terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan -auto-approve
```

SKS Connexion
```
terraform output -json kubeconfig | jq -r . > ~/.kube/config
```

Deploy CSI Longhorn
```
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

## Ingress controler
Exoscale SKS : Install ingress-nginx in the namespace ingress-nginx  
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/exoscale/deploy.yaml
kubectl -n ingress-nginx get svc -w
```
Voici un exemple de fichier YAML pour déployer une application de démonstration accessible via un Ingress Nginx :
```
cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  selector:
    matchLabels:
      app: demo-app
  replicas: 3
  template:
    metadata:
      labels:
        app: demo-app
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
  name: demo-service
spec:
  selector:
    app: demo-app
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: demo.example.com
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: demo-service
                port:
                  name: http
EOF
```

## ArgoCD comme centre névralgique (Maitriser le déploiement de ressources Applicatives)
Install ArgoCD with service in LoadBalancer mode
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl -n argocd get svc -w
```

Retrive default admin password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
		a. Création Demo-App et Sync
		b. Modification version nginx 1.23 -> 1.24 : Vue dans les logs des pods
    
## Kasten pour sauvegarder Applications et Cluster (Maitriser les données hébergées)
		a. Snapshot demo-app
		b. Suppression déploiement demo-app
		c. Restaure snapshot
    
## Observabilté avec Prometheus et Grafana (Maitriser l'utilisation des ressources)
		a. Déploiement Prometheus via yaml repo
		b. Déploiement Grafana via Helm chart et custom values
		c. Création de la data source et Import du Dashboard 315
		
## Linkerd pour la sécurisation de la communication entre les composants (Maitriser les applications)
		a. Installation linkerd et linkerd viz dashboard
		b. Déploiement application de démo
		c. automatically enables mutually-authenticated Transport Layer Security (mTLS) for all TCP traffic between meshed pods
		d. Meshing demo service with annotations
		
## Outils de sécurité : liens vers https://devops.cisel.ch 
## Outils de gestion  : liens vers https://devops.cisel.ch  

