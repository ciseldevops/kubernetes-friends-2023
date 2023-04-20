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
