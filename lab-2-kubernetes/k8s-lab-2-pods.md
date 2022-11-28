# Kubernetes - Lab 2: les pods

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Notre premier Pod

Rappelez-vous, pour l'exercice Docker, notre premier container s'appelait `hello-world`. Voyons si on peut s'en servir à nouveau comme Pod...

**Commande #1**

```
kubectl run hello-world --image=hello-world
```

- `--image=hello-world`: le nom de l'image (et son tag optionnel) du container de notre pod

**Résultat**

```
pod/hello-world created
```

À première vue, ça paraît pas mal. Voyons dans les détails:

**Commande #2**

```
kubectl get pod hello-world --watch
```

- `--watch`: rafraîchit régulièrement le statut du pod

**Résultat**

```
NAME          READY   STATUS             RESTARTS   AGE
hello-world   0/1     Completed          2          31s
hello-world   0/1     CrashLoopBackOff   2          35s
```

Aïe en fait ça va pas du tout: le pod se "complète", il redémarre, il est en erreur... 

`<Ctrl><C>` pour interrompre l'affichage puis voyons pourquoi ce pod ne fonctionne pas:

**Commande #3**

```
kubectl describe pod hello-world
```

**Résultat**

```
(...)
Containers:
  hello-world:
    Container ID:   containerd://040a3f350c09b2153df7b871980856aaffff4a113d33a59fc45a89392da0e202
    Image:          hello-world
    Image ID:       docker.io/library/hello-world@sha256:4cf9c47f86df71d48364001ede3a4fcd85ae80ce02ebad74156906caff5378bc
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
(...)
```

En gros, ce qui se passe c'est que notre container, une fois qu'il a affiché son message se termine (la ligne `Last State:     Terminated`). Or par défault, la `restartPolicy` par défaut pour un pod est de le redémarrer lorsqu'il s'arrête. D'où nos problèmes...

Essayons de recréer notre pod en lui indiquant qu'il ne doit pas redémarrer:

**Commande #4**

```
kubectl delete pod hello-world && kubectl run hello-world --image=hello-world --restart='Never'
```

- `delete pod`: on supprime le pod puis on le recrée

**Résultat**

```
pod "hello-world" deleted
pod/hello-world created
```

Voyons notre pod:

**Commande #5**

```
kubectl get pod hello-world
```

**Résultat**

```
NAME          READY   STATUS      RESTARTS   AGE
hello-world   0/1     Completed   0          39s
```

C'est mieux. Notre pod s'est arrêté et n'a pas redémarré. En fait, c'est un job (nous verrons cela un peu plus tard). La plupart des pods Kubernetes s'appuient sur des "runnable containers", c'est à dire des containers dont le process principal fonctionne en permanence.

Un bon candidat pourrait donc être le container Nginx. Voyons cela:

**Commande #6**

```
kubectl delete pod hello-world && kubectl run nginx --image=nginx:alpine
```

**Résultat**

```
pod "hello-world" deleted
pod/nginx created
```

Voyons l'état de ce nouveau pod:

**Commande #7**

```
kubectl get pod nginx
```

**Résultat**

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          39s
```

Magnifique: son (unique) container est `READY` et le `STATUS` du pod est `Running`.

Vérifions ce qui va se passer si l'on "tue" le process. Rappelez-vous: pour Docker, le process s'arrêtait...

**Commande #8**

```
kubectl exec nginx -- kill -15 1
```

- `exec`: comme pour Docker, on va exécuter une commande sur un pod existant
- `--`: le "séparateur" - tout ce qui suit ce séparateur est la commande à exécuter dans le container du pod
- `kill -15 1`: on tue le processus principal (`1`) du container de notre pod

Voyons l'état de notre pod:

**Commande #9**

```
kubectl get pod nginx
```

**Résultat**

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   1          3m29s
```

Magnifique: cette fois, le scheduler Kubernetes a redémarré notre pod (`RESTARTS` vaut `1`) mais notre pod fonctionne toujours. Nginx est tellement rapide à redémarrer que son temps d'indisponibilité est quasiment nul.

Tiens, regardons un peu ce que font les collègues:

**Commande #10**

```
kubectl get pods --all-namespaces
```

- `--all-namespaces`: on veut voir les pods pour _tous_ les namespaces... mais vous l'aviez compris ?

**Résultat (tronqué)**

```
NAMESPACE     NAME                                   READY   STATUS       RESTARTS   AGE
ibm-system    addon-catalog-source-nrzr2             1/1     Running      0          2d22h
(...)
user1         hello-world-9jl9z                      0/1     StartError   0          22m
user2         hello-world-6g7kL                      0/1     StartError   0          24m
(...)
```

On peut même préciser le namespace:

**Commande #11**

```
kubectl get pods --namespace=user1
```

(remplacez `user1` par un des namespaces que vous avez vu commé réponse à la commande #10)

**Résultat**

```
NAMESPACE     NAME                              READY   STATUS       RESTARTS   AGE
user1         hello-world-9jl9z                 0/1     StartError   0          22m
```

Supprimons ce pod:

**Commande #12**

```
kubectl delete pod nginx
```

**Résultat**

```
pod "nginx" deleted
```

### YAML ?

Nous allons maintenant re-déployer le pod Nginx, mais cette fois nous allons utiliser un fichier YAML pour "décrire" ce pod.

**Commande #13**

Creons le fichier pod.yaml

```bash
touch pod.yaml
```

Editons le fichier pour rajouter le contenu yaml

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
```

En gros:

- `metadata.labels`: nous aurons l'occasion de revenir dessus; en gros on labellise les items Kubernetes (un peu comme on veut) pour pouvoir les retrouver plus tard.
- `ports:` le port du container que l'on souhaite exposer. Nous reverrons cela avec les services.

Déployons notre pod avec ce fichier:

**Commande #14**

```
kubectl apply -f pod.yaml
```

- `apply -f`: appliquer la configuration à partir d'un fichier

**Résultat**

```
pod/nginx created
```

Notre pod est-il prêt ?

**Commande #15**

```
kubectl get pods
```

**Résultat**

```
NAME                READY   STATUS       RESTARTS   AGE
nginx               1/1     Running      0          42s
```

Notre pod est là, prêt et fonctionnel.

Nous allons maintenant créer un pod avec deux containers actifs. On va éditer le fichier YAML pour rajouter un container:

**Commande #16**

```
vi pod.yaml
```

ou

```
nano pod.yaml
```

On va rajouter en toute fin de fichier les lignes suivantes (en gros: on crée un deuxième container qui ne fait que dormir pendant un jour):

```YAML
  - name: sleeping-beauty
    image: alpine
    command:
    - /bin/ash
    - "-c"
    - sleep 86400
```

Pour avoir un YAML de cette forme:

```YAML
(...)
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
  - name: sleeping-beauty
    image: alpine
    command:
    - /bin/ash
    - "-c"
    - sleep 86400
```

**Note: attention à l'indentation du YAML: les deux `- name` doivent être alignés !**

Essayons de mettre à jour notre pod:

**Commande #17**

```
kubectl apply -f pod.yaml
```

- le `apply -f` permet de créer une ressource si elle n'existe pas, mais aussi de la modifier si elle existe. C'est ce qu'on espère faire ici...

**Résultat**

```
The Pod "nginx" is invalid: spec.containers: Forbidden: pod updates may not add or remove containers
```

Loupé! Il va falloir recréer notre pod:

**Commande #18**

```
kubectl delete -f pod.yaml && kubectl apply -f pod.yaml
```

- `delete -f`: ce qu'un `apply` peut faire, le `delete` peut défaire !

**Résultat**

```
pod "nginx" deleted
pod/nginx created
```

Voyons notre pod:

**Commande #19**

```
kubectl get pod/nginx
```

**Résultat**

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   2/2     Running   0          7s
```

Et voilà: un pod, deux containers ! Pour le fun, tuons un des deux processes de containers:

**Commande #20**

```
kubectl exec nginx -c nginx -- kill -15 1
```

- `-c nginx`: le pod ayant deux containers (`nginx`et `sleeping-beauty`), on en choisit un (en l'occurrence: `nginx`)

Vérifions le résultat sur notre pod:

**Commande #21**

```
kubectl describe pod/nginx
```

**Résultat**

```
Events:
  Type    Reason     Age                  From                     Message
  ----    ------     ----                 ----                     -------
  Normal  Scheduled  7m36s                default-scheduler        Successfully assigned user/nginx to 10.144.182.187
  Normal  Pulling    7m35s                kubelet, 10.144.182.187  Pulling image "alpine"
  Normal  Started    7m34s                kubelet, 10.144.182.187  Started container sleeping-beauty
  Normal  Pulled     7m34s                kubelet, 10.144.182.187  Successfully pulled image "alpine"
  Normal  Created    7m34s                kubelet, 10.144.182.187  Created container sleeping-beauty
  Normal  Created    46s (x2 over 7m35s)  kubelet, 10.144.182.187  Created container nginx
  Normal  Pulled     46s (x2 over 7m35s)  kubelet, 10.144.182.187  Container image "nginx:alpine" already present on machine
  Normal  Started    45s (x2 over 7m35s)  kubelet, 10.144.182.187  Started container nginx
```

On voit que le container `nginx` a été recréé (le `x2`), ce qui est normal après notre tentative de suppression...

Allez, on supprime ce pod pour terminer:

**Commande #22**

```
kubectl delete pod nginx
```

On pouvait aussi faire un `k delete -f pod.yaml`... mais varions les plaisirs !