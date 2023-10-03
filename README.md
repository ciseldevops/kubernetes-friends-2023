# kubernetes-friends-2023
Fribourg Linux Seminar - Kubernetes Friends


# Summary
- Exoscale : The Hosting Friend
- Terraform : The IaC Friend
- ArgoCD : The Deployment Friend
- Kasten : The Backup and DR Friend
- Prometheus and Grafana : The Observability Friends
- Trivy & Kubescape & GitLeaks : Security
- _ingress-nginx : The Ingress Friend_
- _Linkerd : The Service Mesh Friend_
- _Longhorn  : The Storage Friend_



## Deploy SKS cluster on Kubernetes using terraform
S3 Access setup
```
vi ~/.aws/credentials
[default]
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
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.x/deploy/longhorn.yaml
kubectl -n longhorn-system get pods -w
```
Access Longhorn dashboard at http://127.0.0.1:7000
```
kubectl -n longhorn-system port-forward deployment/longhorn-ui 7000:8000 
```


## Deploy ArgoCD on the cluster

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
Deploy Demo-App using ArgoCD
```
Name : demo-app
Project : default
Repository URL : https://github.com/ciseldevops/kubernetes-friends-2023.git
Path : ./demo-app
Namespace : demo-app
Create namespace : True
```

## Ingress controler
Exoscale SKS : Install ingress-nginx in the namespace ingress-nginx  
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/exoscale/deploy.yaml
kubectl -n ingress-nginx get svc -w
```
Here is an example of a YAML file to deploy a demo application accessible via an Ingress Nginx :
```
kubectl apply -f https://raw.githubusercontent.com/ciseldevops/kubernetes-friends-2023/main/demo-app/demo-app.yaml
```
    
## Kasten to back up Applications and Cluster

Exoscale create snapshot class
```
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-4.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl -n kube-system apply -f https://raw.githubusercontent.com/ciseldevops/kubernetes-friends-2023/main/kasten/snap-config.yaml

```

Validate CSI setup
```
helm repo add kasten https://charts.kasten.io --force-update && helm repo update
curl -s https://docs.kasten.io/tools/k10_primer.sh | bash
```

Install Kasten using Helm
```
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

Take demo-app snapshot

Delete demo-app deployment
```
kubectl -n demo-app delete deployments.apps demo-app
```

Restore demo-app using the snapshot

    
## Observability with Prometheus and Grafana

Prometheus deployment
```
kubectl create ns monitoring
kubectl -n monitoring apply -f obs/prometheus.yaml
kubectl -n monitoring get all
```
Create Grafana App in ArgoCD
```
Name : grafana
Repo URL :  https://grafana.github.io/helm-charts/
Chart : Grafana
Version : 6.54.0
Namespace : monitoring

VALUES :
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

Patch ingress class and get the secrets
```
kubectl -n monitoring patch ingress grafana -p '{"spec":{"ingressClassName":"nginx"}}'
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo
```

Add Prometheus Data Source
```
kubectl -n monitoring describe service prometheus
URL : http://prometheus.internal.url:9090
```
Access Prometheus using port-forward http://127.0.0.1:9090
```
kubectl --namespace monitoring port-forward service/prometheus 9090:9090
container_network_receive_bytes_total
```

Import Grafana Dashboard 315

## Trivy

Get all the containers images from all the namespaces
```
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq
```

Scan image for known CVE
```
trivy image nginx:1.23
trivy image --severity CRITICAL nginx:1.23
```
Compare with an older image, like nginx:1.19
```
trivy image --severity CRITICAL nginx:1.19
```

## GitLeaks

Check if there are secrets in your codes using entropy
```
gitleaks detect -v --no-git
```
## Terrascan

Scan your Kubernetes deployment codes against Best Practice
```
terrascan scan -i k8s --iac-dir kubernetes-friends-2023/
terrascan scan -i k8s --iac-file kubernetes-friends-2023/demo-app/demo-app.yaml
```
Scan your terraform codes agains Best Practice 
```
terrascan scan -i terraform --iac-file kubernetes-friends-2023/sksfls.tf
```

## Kubescape (Or kube-bench)

Scan your Kubernetes CLuster against CIS Benchmark
```
kubescape scan framework cis-v1.23-t1.0.1 --enable-host-scan
kubescape scan framework cis-v1.23-t1.0.1 --enable-host-scan --verbose
```





## Linkerd for securing communication between components
		
Install linkerd locally
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
linkerd viz dashboard &
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

## Debug
```
kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh
```

## Destroy SKS Cluster
```
terraform destroy -auto-approve
```
