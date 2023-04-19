
Azure - Create a volume snapshot class
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml
kubectl annotate VolumeSnapshotClass csi-azuredisk-vsc k10.kasten.io/is-snapshot-class="true"
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
```

Generate temp Token for admin access
```
kubectl -n kasten-io create token k10-k10 --duration=24h
```
