
kubectl version --short

Install CLI
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/XXXXX/.linkerd2/bin
linkerd version


Validate cluster and install linkerd
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
linkerd check

Source : https://linkerd.io/2.13/getting-started/
