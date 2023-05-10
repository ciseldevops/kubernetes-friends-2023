Backup SKS Cluster in case of Murphy's law

Access setup
```
export EXOSCALE_API_KEY=...
export EXOSCALE_API_SECRET=...
```

SKS deployment
```
terraform init
terraform plan -out main.tfplan
terraform apply -auto-approve main.tfplan
```

SKS Connexion
```
terraform output -json kubeconfig | jq -r . > ~/.kube/config
```

Deploy CSI Longhorn
```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/1.4.1/deploy/longhorn.yaml
kubectl port-forward deployment/longhorn-ui 7000:8000 -n longhorn-system
```
Access Longhorn dashboard at http://127.0.0.1:7000
