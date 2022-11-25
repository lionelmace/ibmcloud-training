# Kubernetes - Lab 5: les services

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Encore Nginx !

Nous allons partir du déploiement Nginx du lab 3:

**Commande #1**

```
kubectl apply -f ~/k8s-labs/2-k8s-base/3-deployments/deployment.yaml
```

**Résultat**

```
deployment.apps/nginx-deployment created
```

On a - si tout va bien - un déploiement avec 2 ou 3 pods Nginx:

**Commande #2**

```
kubectl get pods -l app=nginx
```

**Résultat**

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c559d5697-764hl   1/1     Running   0          3m53s
nginx-deployment-5c559d5697-rpxls   1/1     Running   0          3m53s
nginx-deployment-5c559d5697-t2nwp   1/1     Running   0          3m53s
```

*Note: vous pouvez n'avoir que 2 pods au lieu de 3 puisque nous avons modifié ce fichier dans le lab 2.*

Bien. Maintenant, nous allons créer le service correspondant à ce déployment:

**Commande #3**

```
kubectl expose deployment/nginx-deployment
```

**Résultat**

```
service/nginx-deployment exposed
```

Facile non ? Voyons le service créé:

**Commande #4**

```
kubectl get services -o wide
```

- `-o wide`: pour avoir une vue détaillée

**Résultat**

```
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
nginx-deployment   ClusterIP   172.21.123.229   <none>        80/TCP    57s   app=nginx
```

On a créé un service de type `ClusterIP` qui expose le poprt 80 (celui du container `nginx`, défini dans me `deployment.yaml`).

Voyons le YAML correspondant:

**Commande #5**

```
kubectl get service/nginx-deployment -o yaml
```

- `-o yaml`: on affiche le résultat au format YAML.

**Résultat**

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2020-09-16T09:28:37Z"
  labels:
    app: nginx
  name: nginx-deployment
  namespace: student
  resourceVersion: "173770"
  selfLink: /api/v1/namespaces/student/services/nginx-deployment
  uid: a2f8d254-1199-43e6-a18b-99659115ac7d
spec:
  clusterIP: 172.21.246.202
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

On remarque surtout le lien entre le service et les pods: il se fait via le `selector` (`app=nginx`).

Essayons maintenant de nous connecter à ce service à partir d'un *nouveau* pod:

**Commande #6**

```
kubectl run -it --rm --image=alpine --restart=Never -- ash
```

- `-it`: comme Docker: `i`nteractive with `t`ty
- `-- ash`: exécute le shell alpine

**Résultat**

```
If you don't see a command prompt, try pressing enter.
/ #
```

Nous sommes dans notre container. Essayons de faire une requête HTTP vers notre service:

**Commande #7 (depuis le container Alpine)**

```
wget nginx-deployment -O -
```

- `-O -`: affiche le contenu de la page

**Résultat**

```
Connecting to nginx-deployment (172.21.246.202:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
(...)
```

Splendide: on arrive à accéder à (un de nos containers) Nginx via le nom du service !

À noter: bien que nous ayions 3 pods (donc 3 adresses IP), le service "expose" une unique IP (ici: `172.21.246.202`).

On peut quitter le terminal en tapant `exit` ou `<Ctrl><D>`.

Si le service expose une unique adresse IP, voyons comment les requêtes sont routées vers nos pods. Pour cela, créons on pod qui va régulièrement faire des requêtes vers notre service:

**Commande #8**

```
cd ~/k8s-labs/2-k8s-base/5-services/
cat poller.yaml
```

**Résultat**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: poller
  labels:
    name: poller
spec:
  containers:
  - name: poller
    image: alpine
    command: ['ash', '-c', 'echo "Starting to poll"; while true; do wget nginx-deployment -O -; sleep 2; done']

```

Simple: on se base sur le container Alpine et on vient requêter notre service Nginx toutes les 2 secondes. Mettons le en œuvre:

**Commande #9**

```
kubectl apply -f poller.yaml
```

**Résultat**

```
pod/poller created
```

Tiens allons voir ses logs mises à jour en temps réél:

**Commande #10**

```
k logs -f poller
```

- `-f`: `follow` (suivre) les logs

**Résultat**

```
Starting to poll
Connecting to nginx-deployment (172.21.246.202:80)
writing to stdout
-                    100% |********************************|   612  0:00:00 ETA
written to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
```

On peut arrêter l'affichage des logs avec `<Ctrl><C>`.

Voyons voir ce qui se passe du côté de nos pods. Pour cela, on va utiliser à nouveau notre sympathique petit utilitaire (Stern) qui va nous afficher les logs de tous les containers de tous les pods de notre déployment:

**Commande #11**

```
stern nginx-deployment
```

**Résultat**

```
nginx-deployment-5c559d5697-482dn nginx 172.30.106.80 - - [16/Sep/2020:10:15:17 +0000] "GET ...
nginx-deployment-5c559d5697-482dn nginx 172.30.106.80 - - [16/Sep/2020:10:15:19 +0000] "GET ...
nginx-deployment-5c559d5697-tfmbr nginx 172.30.106.80 - - [16/Sep/2020:10:15:21 +0000] "GET ...
nginx-deployment-5c559d5697-tfmbr nginx 172.30.106.80 - - [16/Sep/2020:10:15:23 +0000] "GET ...
nginx-deployment-5c559d5697-482dn nginx 172.30.106.80 - - [16/Sep/2020:10:15:25 +0000] "GET ...
nginx-deployment-5c559d5697-fqk5r nginx 172.30.106.80 - - [16/Sep/2020:10:15:27 +0000] "GET ...
nginx-deployment-5c559d5697-fqk5r nginx 172.30.106.80 - - [16/Sep/2020:10:15:29 +0000] "GET ...
nginx-deployment-5c559d5697-fqk5r nginx 172.30.106.80 - - [16/Sep/2020:10:15:31 +0000] "GET ...
nginx-deployment-5c559d5697-482dn nginx 172.30.106.80 - - [16/Sep/2020:10:15:33 +0000] "GET ...
```

On peut arrêter l'affichage des logs avec `<Ctrl><C>`.

Si votre terminal est compatible, chaque pod affiche ses logs avec une couleur spécifique. On voit bien que les requêtes sont réparties (aléatoirement) vers chacun des pods de notre deployment. Le service agit comme un "load balancer".

Supprimons notre poller:

**Commande #12**

```
kubectl delete pod/poller
```

**Résultat**

```
pod "poller" deleted
```

Supprimons également notre service:

**Commande #13**

```
kubectl delete service/nginx-deployment
```

**Résultat**

```
service "nginx-deployment" deleted
```

Nous allons maintenant exposer notre service Nginx avec un Node Port; voyons comment faire:

**Commande #14**

```
cat nodeport.yaml
```

**Résultat**

```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    protocol: TCP
```

- `type: NodePort`: c'est ce que l'on veut faire
- `port: 80`: le port exposé au niveau du container
- à noter que c'est Kubernetes qui va nous assigner un Node Port spécifique

**Commande #15**

```
k apply -f nodeport.yaml
```

**Résultat**

```
service/nginx-nodeport created
```

Vérifions:

**Commande #16**

```
k get service/nginx-nodeport -o wide
```

**Résultat**

```
NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
nginx-nodeport   NodePort   172.21.144.16   <none>        80:30617/TCP   16s   app=nginx
```

Super: notre Node Port a été assigné, c'est le `30617` ici (chaque participant aura son propre Node Port).

Vous pouvez vous connecter avec votre browser préféré pour accéder à: `http://**CLUSTER_BASE_URL**:**NODE_PORT**`. Le `CLUSTER_BASE_URL` vous a été transmis par mail.

Nettoyons nos traces:

**Commande #17**

```
k delete -f nodeport.yaml && k delete deployment/nginx-deployment
```

**Résultat**

```
service "nginx-nodeport" deleted
deployment.apps "nginx-deployment" deleted
```

