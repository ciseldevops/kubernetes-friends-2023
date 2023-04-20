Deploy SKS cluster on Kubernetes using terraform

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
