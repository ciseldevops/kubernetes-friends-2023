# kubernetes-friends-2023
Fribourg Linux Seminar - Kubernetes Friends


# Summary
- Terraform : The IaC Friend
- Longhorn  : The Storage Friend 
- ingress-nginx : The Ingress Friend
- ArgoCD : The Deployment Friend
- Kasten : The Backup and DR Friend
- Prometheus and Grafana : The Observability Friends
- Linkerd : The Service Mesh Friend


## Deploy SKS cluster on Kubernetes using terraform
S3 Access setup
```
vi ~/.aws/credentials
aws_access_key_id = ***
aws_secret_access_key = ***
```

API Access setup
```
export EXOSCALE_API_KEY=***
export EXOSCALE_API_SECRET=***
```

SKS deployment
```
cd sks
terraform init
terraform plan -out main.tfplan
terraform apply -auto-approve main.tfplan

```

SKS Connection
```
terraform output -json kubeconfig | jq -r . > ~/.kube/config
watch kubectl get nodes -A
```

## Deploy CSI Longhorn
```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/1.4.1/deploy/longhorn.yaml
kubectl port-forward deployment/longhorn-ui 7000:8000 -n longhorn-system
```
Access Longhorn dashboard at http://127.0.0.1:7000

## Ingress controler
Exoscale SKS : Install ingress-nginx in the namespace ingress-nginx  
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/exoscale/deploy.yaml
kubectl -n ingress-nginx get svc -w
```
Here is an example of a YAML file to deploy a demo application accessible via an Ingress Nginx :
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

## ArgoCD as a nerve center (Controlling the deployment of application resources)
		a. Création Demo-App et Sync
		b. Modification version nginx 1.23 -> 1.24 : Vue dans les logs des pods
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

    
## Kasten to back up Applications and Cluster
		a. Snapshot demo-app
		b. Suppression déploiement demo-app
		c. Restaure snapshot
Exoscale create snapshot class
```
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/ciseldevops/kubernetes-friends-2023/main/kasten/snap-config.yaml

```

Validate CSI setup
```
curl -s https://docs.kasten.io/tools/k10_primer.sh | bash
```

Install Kasten using Helm
```
helm repo add kasten https://charts.kasten.io --force-update && helm repo update
kubectl create ns kasten-io
helm install k10 kasten/k10 --namespace=kasten-io --set auth.tokenAuth.enabled=true
kubectl -n kasten-io get pods -w
```

Generate temp Token for admin access
```
kubectl -n kasten-io create token k10-k10 --duration=24h
```

Access web interface at http://127.0.0.1:8080/k10/#/
```
kubectl --namespace kasten-io port-forward service/gateway 8080:8000
```

    
## Observability with Prometheus and Grafana (Controlling the use of resources)
		a. Déploiement Prometheus via yaml repo
		b. Déploiement Grafana via Helm chart et custom values
		c. Création de la data source et Import du Dashboard 315
Prometheus deployment
```
kubectl create ns monitoring
kubectl -n monitoring apply -f kubernetes-friends-2023/obs/prometheus.yaml
```
Create Grafana App in ArgoCD
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

		
## Linkerd for securing communication between components (Mastering applications)
		a. Installation linkerd et linkerd viz dashboard
		b. Déploiement application de démo
		c. automatically enables mutually-authenticated Transport Layer Security (mTLS) for all TCP traffic between meshed pods
		d. Meshing demo service with annotations
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
```

Uninstall
```
linkerd viz uninstall | kubectl delete -f -
linkerd uninstall | kubectl delete -f -
```
		
## Some Security Tools : [https://devops.cisel.ch ](https://devops.cisel.ch/kubernetes-containers-and-code-security-tools)
## Some Ops Tools  : [https://devops.cisel.ch  ](https://devops.cisel.ch/kubernetes-operational-tools-you-must-try)

