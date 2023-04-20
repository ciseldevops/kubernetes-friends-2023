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





Azure - Create a volume snapshot class
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml
kubectl annotate VolumeSnapshotClass csi-azuredisk-vsc k10.kasten.io/is-snapshot-class="true"
```
