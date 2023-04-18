Comment déployer Traefik et Traefik Pilot sur un cluster SKS
Déploiement de Traefik

Voici les étapes à suivre pour déployer Traefik sur votre cluster SKS :

    Créez un fichier YAML pour les ressources Traefik :

yaml

# traefik.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-web-ui
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.example.com`) && PathPrefix(`/api`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
  - match: Host(`traefik.example.com`) && PathPrefix(`/dashboard`)
    kind: Rule
    services:
      - name: api@internal
        kind: TraefikService
        passHostHeader: true
  - match: Host(`traefik.example.com`)
    kind: Rule
    services:
      - name: traefik-web-ui
        kind: Service
        namespace: kube-system
        port: 8080

    Créez le secret pour Traefik :

shell

$ kubectl create secret generic traefik-cert --from-file=tls.crt=traefik.crt --from-file=tls.key=traefik.key -n kube-system

    Créez le déploiement et le service Traefik :

shell

$ kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.5/examples/k8s/traefik-deployment.yaml

    Créez le service NodePort pour le WebUI de Traefik :

shell

$ kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.5/examples/k8s/ui.yaml

    Créez la ressource IngressRoute pour le WebUI de Traefik :

shell

$ kubectl apply -f traefik.yaml

Déploiement de Traefik Pilot

Voici les étapes à suivre pour déployer Traefik Pilot sur votre cluster SKS :

    Créez le secret pour Traefik Pilot :

shell

$ kubectl create secret generic traefik-pilot-cert --from-file=tls.crt=pilot.crt --from-file=tls.key=pilot.key -n kube-system

    Créez le fichier de configuration YAML pour le déploiement de Traefik Pilot :

yaml

# traefik-pilot.yaml
apiVersion: traefik.io/v1alpha1
kind: Pilot
metadata:
  name: traefik-pilot
  namespace: kube-system
spec:
  token: "YOUR_PILOT_TOKEN"
  static:
    ingress:
      enabled: true
      kubeConfig: "/etc/traefik/pilot-kubeconfig.yaml"
      routeConfigFile: "/etc/traefik/route-config.yaml"
  dynamic:
    kubernetes:
      labelSelector: "app.kubernetes.io/name=traefik-pilot,app.kubernetes.io/instance=traefik-pilot"
      namespaces:
        - kube-system
      watch: true

Assurez-vous de remplacer YOUR_PILOT_TOKEN par votre propre token.

    Créez le fichier de configuration YAML pour le Service
