Pour déployer Traefik et Traefik Pilot sur un cluster SKS, vous pouvez suivre les étapes suivantes :

Ajouter le référentiel Helm de Traefik :


helm repo add traefik https://helm.traefik.io/traefik
helm repo update

Créer un namespace pour Traefik :


kubectl create namespace traefik

Installer Traefik avec Helm :


helm install traefik traefik/traefik \
  --namespace traefik \
  --values https://raw.githubusercontent.com/traefik/traefik/v2.5/examples/k8s/traefik-values.yaml

Vérifier que le déploiement de Traefik est terminé :

kubectl get pods -n traefik

Installer Traefik Pilot avec Helm :

helm install traefik-pilot traefik/traefik-pilot \
  --namespace traefik \
  --set pilot.token=<YOUR_PILOT_TOKEN>

Vérifier que le déploiement de Traefik Pilot est terminé :

    kubectl get pods -n traefik

Notez que pour déployer Traefik Pilot, vous devez générer un jeton d'authentification et le passer à la commande helm install. Vous pouvez générer un jeton en utilisant la commande suivante :


openssl rand -hex 16

Assurez-vous également de remplacer <YOUR_PILOT_TOKEN> dans la commande d'installation de Traefik Pilot par le jeton que vous avez généré.

