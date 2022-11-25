# Kubernetes - Lab 3: les deployments

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Les deployments: replica sets

C'est le retour du YAML... il va falloir s'y habituer ! Nous allons donc créer notre premier deployment.

**Commande #1**

```
cd ~/k8s-labs/2-k8s-base/3-deployments
cat deployment.yaml
```

**Résultat**

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

- `replicas: 3` on veut à tout moment 3 pods Nginx fonctionnels.
- `ports:` le port du container que l'on souhaite exposer. Nous reverrons cela avec les services.

Nous allons maintenant effectuer notre déploiement:

**Commande #2**

```
kubectl apply -f deployment.yaml
```

**Résultat**

```
deployment.apps/nginx-deployment created
```

Bien. Voyons voir ce qui a été fait:

**Commande #3**

```
kubectl get pods -l app=nginx
```

- `-l app=nginx`: c'est un selector, qui nous permet de n'afficher que les pods dont le label `app` vaut `nginx`

**Résultat**

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c559d5697-dqn4s   1/1     Running   0          35s
nginx-deployment-5c559d5697-lxj85   1/1     Running   0          35s
nginx-deployment-5c559d5697-rwjvn   1/1     Running   0          35s
```

Super: on a bien nos 3 pods. Ils ont un nom bizarre: c'est normal. Chaque nom de pod devant être unique, le scheduler lui adjoint un suffixe garantissant l'unicité de son nom.

Essayons de supprimer un pod:

**Commande #4**

```
kubectl delete pod XXX
```

(remplacer `XXX` par le nom d'un de vos pods Nginx)

**Résultat**

```
pod "XXX" deleted
```

Vérifions nos pods:

**Commande #5**

```
kubectl get pods
```

**Résultat**

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c559d5697-g4jbm   1/1     Running   0          10s
nginx-deployment-5c559d5697-lxj85   1/1     Running   0          4m25s
nginx-deployment-5c559d5697-rwjvn   1/1     Running   0          4m25s
```

Toujours 3... donc un tout neuf (ici: le premier). Tout va bien ! 

*Note: il s'agit d'un mécanisme différent de celui que nous avons vu avec les pods: on est un "niveau" au dessus: le pod redémarre les containers, le deployment recrée les pods supprimés.*

Nous allons maintenant modifier les paramètres de notre déploiement en mettant à jour le fichier de déploiement:

**Commande #6**

```
vi deployment.yaml
```

ou

```
nano deployment.yaml
```

(choisissez votre éditeur préféré)

Déplacez-vous sur la ligne:

```YAML
  replicas: 3
```

et remplacer le `3` par un `2`. 

Sauvegardez puis:

**Commande #7**

```
kubectl apply -f deployment.yaml
```

**Résultat**

```
deployment.apps/nginx-deployment configured
```

Voyons nos pods:

**Commande #8**

```
kubectl get pods -l app=nginx
```

**Résultat**

```NAME                                READY   STATUS    RESTARTS   AGE
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c559d5697-lxj85   1/1     Running   0          11m
nginx-deployment-5c559d5697-rwjvn   1/1     Running   0          11m
```

Il n'y en a plus que 2 ! Notez que les pods existants n'ont pas été redémarrés, seul le pod "indésirable" a été supprimé.

On peut maintenant supprimer notre deployment:

**Commande #9**

```
kubectl delete -f deployment.yaml
```

**Résultat**

```
deployment.apps "nginx-deployment" deleted
```

### Les stateful sets

La encore, nous allons nous appuyer sur un fichier YAML.

**Commande #10**

```
cat statefulset.yaml
```

**Résultat**

```YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-statefulset
  labels:
    app: nginx
spec:
  serviceName: nginx
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

À noter ici la ligne `serviceName: nginx`; nous reparlerons de la notion de service plus tard.

Créons notre stateful set:

**Commande #11**

```
kubectl apply -f statefulset.yaml
```

**Résultat**

```
statefulset.apps/nginx-statefulset created
```

Voyons un peu les pods créés:

**Commande #12**

```
kubectl get pods -l app=nginx
```

**Résultat**

```
NAME                  READY   STATUS    RESTARTS   AGE
nginx-statefulset-0   1/1     Running   0          4m21s
nginx-statefulset-1   1/1     Running   0          4m19s
nginx-statefulset-2   1/1     Running   0          4m17s
```

Ah cette fois les noms de pods sont plus sympathiques... noter l'ordre de création: d'abord le `-2`, ensuite le `-1` et enfin le `-0`. Un point important: les nom d'hôte de nos containers sont aussi "prévisibles", contairement au replica set / deployment:

**Commande #13**

```
kubectl exec nginx-statefulset-1 -- hostname
```

- on exécute la commande `hostname` dans l'unique container du pod `nginx-statefulset-1`

**Résultat**

```
nginx-statefulset-1
```

Voilà qui est fort utile pour pouvoir identifier nos hosts individuellement.

Pour terminer, supprimons ce statefulset:

**Commande #14**

```
kubectl delete -f statefulset.yaml
```

**Résultat**

```
statefulset.apps "nginx-statefulset" deleted
```
