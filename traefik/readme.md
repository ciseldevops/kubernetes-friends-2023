#Déploiement de Traefik et Traefik Pilot sur un cluster SKS
##Prérequis

Avant de commencer, vous devez avoir un cluster SKS fonctionnel et une connexion au cluster via la CLI Exoscale.
Étapes

    Créez un namespace pour Traefik :

arduino

kubectl create namespace traefik

    Ajoutez le repo helm de Traefik :

csharp

helm repo add traefik https://helm.traefik.io/traefik
helm repo update

    Installez Traefik :

arduino

helm install traefik traefik/traefik --namespace traefik --set service.type=LoadBalancer --set pilot.enabled=true --set pilot.token="votre-token" --set pilot.dashboard.enabled=true

    Vérifiez que Traefik est correctement déployé :

sql

kubectl get all -n traefik

Vous devriez voir une sortie similaire à celle-ci :

bash

NAME                           READY   STATUS    RESTARTS   AGE
pod/traefik-79fbcdbdfd-ck4s4   1/1     Running   0          58s

NAME              TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                     AGE
service/traefik   LoadBalancer   10.104.221.10   185.203.119.2   80:32674/TCP,443:31181/TCP,8080:31452/TCP   58s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/traefik   1/1     1             1            58s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/traefik-79fbcdbdfd   1         1         1       58s

    (Optionnel) Si vous avez activé Traefik Pilot, vous pouvez accéder à son interface via l'adresse IP externe du service Traefik et le port 8080. Pour obtenir le mot de passe, vous devez récupérer le jeton créé lors de l'installation :

arduino

kubectl get secret traefik-pilot -n traefik -o jsonpath='{.data.token}' | base64 -d

    (Optionnel) Vous pouvez également déployer Traefik Pilot en tant que chart Helm séparé :

arduino

helm install traefik-pilot traefik/traefik-pilot --namespace traefik --set pilot.token="votre-token" --set pilot.dashboard.enabled=true

Et voilà ! Vous devriez maintenant avoir Traefik et Traefik Pilot déployés sur votre cluster SKS.
