# Kubernetes - Lab 6: le registre privé IBM Cloud

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Pour changer: un peu de Node.JS

Node.JS est un framework qui permet de développer des applictions "backend" en Javascript. Nous allons construire (et modifier) une image Docker Node.JS sur le registre IBM Cloud (privé) et l'exécuter sur notre cluster.

Voyons de quoi il retourne:

**Commande #1**

```
cd ~/k8s-labs/2-k8s-base/6-ibm-registry
more * | cat
```

**Résultat**

```
::::::::::::::
Dockerfile
::::::::::::::
FROM node:14
ARG user
ENV user=$user
WORKDIR /usr/src/app
COPY package*.json app.js ./
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
::::::::::::::
app.js
::::::::::::::
const express = require('express')
const app = express()
var name = process.env.user || "someone"
app.get('/', (req, res) => res.send('Hello World from ' + name + '!'))
app.listen(3000, () => console.log('Server ready'))
::::::::::::::
package.json
::::::::::::::
{
  "name": "ibm-registry-lab",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}
```

- `Dockerfile`: on se base sur l'image `node` en version `14`. On copie les deux fichiers (`package.json` et `app.js`) et on installe les dépendances (`npm install`). On récupère aussi une variable d'environnement `user`.

- `app.js`: en gros: on démarre un serveur d'application sur le port `3000` et lorsqu'un `GET` HTTP esr reçu sur ce port, on affiche `Hello World from ` suivi du contenu de la variable d'environnement `user` (ou de `someone` si cette variable est vide).

- `package.json`: le fichier de configuration de l'application avec ses dépendances.

**Commande #2**

C'était il n'y a pas si longtemps... le lab Docker ! On va construire l'image localement:

```
docker build --build-arg user=$USER -t node .
```

- `--build-arg user=$USER`: on passe le contenu de notre variable `USER` au Docker daemon en l'assignant à la variable `user`.

**Résultat**

```
Sending build context to Docker daemon  4.096kB
Step 1/8 : FROM node:14
 ---> 173eeb895217
Step 2/8 : ARG user
 ---> Using cache
 ---> f1b025e2fb36
Step 3/8 : ENV user=$user
 ---> Running in 7a2da8baf4d5
Removing intermediate container 7a2da8baf4d5
 ---> d2004ba43ee5
Step 4/8 : WORKDIR /usr/src/app
 ---> Running in fbc4f5d37337
Removing intermediate container fbc4f5d37337
 ---> 6178045f1494
Step 5/8 : COPY package*.json app.js ./
 ---> a1a4d892bdb6
Step 6/8 : RUN npm install
 ---> Running in 7bd9e155ef9a
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN ibm-registry-lab@1.0.0 No description
npm WARN ibm-registry-lab@1.0.0 No repository field.

added 50 packages from 37 contributors and audited 50 packages in 1.466s
found 0 vulnerabilities

Removing intermediate container 7bd9e155ef9a
 ---> e6acb5759141
Step 7/8 : EXPOSE 3000
 ---> Running in a0c7e816c3db
Removing intermediate container a0c7e816c3db
 ---> 3b19ae058adf
Step 8/8 : CMD ["node", "app.js"]
 ---> Running in 413a62ff3334
Removing intermediate container 413a62ff3334
 ---> 3a2986ff1b3b
Successfully built 3a2986ff1b3b
Successfully tagged node:latest
```

Bien. L'image est prête. Démarrons notre container:

**Commande #3**

```
docker run -p 80:3000 -d --name node node
```

- `-p 80:3000`: le port `80` de notre serveur est redirigé vers le port `3000` du container (l'instruction `EXPOSE` du `Dockerfile`).

**Résultat**

```
b4aca1a7351fa3dda95124f6a9669d5b67e051fc356e12a10961d1e10a039fde
```

l'ID du container.

Vérifions que notre appli fonctionne; au choix on peut faire:

**Commande #4**

```
curl localhost:80
```

**Résultat**

```
Hello World from student!
```

Ou aller directement sur `http://**IP_DE_VOTRE_VM**`.

Tout va bien. Supprimons ce container:

**Commande #5**

```
docker rm -f node
```

**Résultat**

```
node
```

Voilà qui est fait.

### Ici Londres

Nous allons utiliser un registre privé sur IBM Cloud hébergé à Londres.

**Commande #6**

```
ibmcloud cr region-set eu-gb
```

**Résultat**

```
The region is set to 'uk-south', the registry is 'uk.icr.io'.

OK
```

Nous allons maintenant lancer le build de l'image sur IBM Cloud:

**Commande #7**

```
i cr build -t k8s-lab/node-${USER} --build-arg user=$USER .
```

- `i`: un autre alias (pour `ibmcloud`)
- `k8s-lab/`: notre "namespace" sur le registre IBM Cloud (à Londre donc)

Noter la syntaxe: `docker` est remplacé par `i cr`; les autres arguments restant quasiment identiques.

**Résultat**

```
Sending build context to Docker daemon  4.096kB
Step 1/8 : FROM node:14
 ---> 173eeb895217
Step 2/8 : ARG user
 ---> Using cache
 ---> b7287d8c3fd1
Step 3/8 : ENV user=$user
 ---> Using cache
 ---> 7d5d5a19ed8c
Step 4/8 : WORKDIR /usr/src/app
 ---> Using cache
 ---> 9b9395c38a85
Step 5/8 : COPY package*.json app.js ./
 ---> Using cache
 ---> 41bb8bc1e51c
Step 6/8 : RUN npm install
 ---> Using cache
 ---> 3dfa0d4f0ae1
Step 7/8 : EXPOSE 3000
 ---> Using cache
 ---> 755a0e0a640c
Step 8/8 : CMD ["node", "app.js"]
 ---> Using cache
 ---> 9b8af2c81d6b
Successfully built 9b8af2c81d6b
Successfully tagged private.uk.icr.io/k8s-lab/node-student:latest
The push refers to repository [private.uk.icr.io/k8s-lab/node-student]
d86cd812f16a: Pushed
824c17cf5e14: Pushed
796f6c5c7553: Pushed
24a8e30559a7: Pushed
58b4b808347b: Pushed
e404bec46f40: Pushed
174e334f3f46: Pushed
cbe6bbd0c86f: Pushed
ef5de533cb53: Pushed
a4c504f73441: Pushed
e8847c2734e1: Pushed
b323b70996e4: Pushed
latest: digest: sha256:e140f3a482407700ca49e68f419d406e7474e26903f737b90cd01d528ef18d42 size: 2840

OK
```

On note deux différences avec le `docker build` de la commande #2:

- L'image est construite _sur IBM Cloud_: le Docker daemon d'IBM Cloud ne reçoit que le contenu du dossier local (`Dockerfile`, `app.js`et `package.json`); le reste des opérations se fait sur le cloud, ce qui est bien commode quand la bande passante de notre machine locale est limitée !
- L'image est taggée et publiée sur le registre privé d'IBM Cloud

Vérifions que notre image est bien présente:

**Commande #8**

```
i cr images --restrict k8s-lab
```

**Résultat**

```
Listing images...

Repository                       Tag      Digest         Namespace   Created         Size     Security status
uk.icr.io/k8s-lab/node-student   latest   e140f3a48240   k8s-lab     9 minutes ago   363 MB   3 Issues

OK
```

Super. Selon les cas, vous verrez sûrement les images des autres participants... sauf si vous êtes le premier !

À noter que cette image semble avoir des problèmes (`3 issues`). Voyons cela en détails:

**Commande #9**

```
i cr va uk.icr.io/k8s-lab/node-student:latest
```

- `va`: `vulnerability` `a`dvisor

*Note: il peut être nécessaire de patienter quelques instants que le scan de l'image ait pû être fait sur IBM Cloud (vous aurez dans ce cas une erreur de type `BXNVA0009E`)*

**Résultat**

```
Checking security issues for 'uk.icr.io/k8s-lab/node-student:latest'...

Image 'uk.icr.io/k8s-lab/node-student:latest' was last scanned on Wed Sep 16 14:18:40 UTC 2020
The scan results show that 3 ISSUES were found for the image.

Configuration Issues Found
==========================

Configuration Issue ID                     Policy Status   Security Practice                                    How to Resolve
application_configuration:mysql.ssl-ca     Active          A setting in /etc/mysql/my.cnf that specifies the    ssl-ca is not specified in /etc/mysql/my.cnf.
                                                           Certificate Authority (CA) certificate.
application_configuration:mysql.ssl-cert   Active          A setting in /etc/mysql/my.cnf that specifies the    ssl-cert is not specified in /etc/mysql/my.cnf
                                                           server public key certificate. This certificate      file.
                                                           can be sent to the client and authenticated
                                                           against its CA certificate.
application_configuration:mysql.ssl-key    Active          A setting in /etc/mysql/my.cnf that identifies the   ssl-key is not specified in /etc/mysql/my.cnf.
                                                           server private key.

OK
```

En gros: il y a des problèmes liés à des certificats SSL sur notre image. Bon à savoir... comme nous n'avons pas défini de restriction de déploiement pour nos images, rien ne nous empêche d'aller plus loin.

Nous allons maintenant créer un pod qui se base sur cette image:

**Commande #10**

```
kubectl run node --image=uk.icr.io/k8s-lab/node-$USER
```

**Résultat**

```
pod/node created
```

Attendons que le pod soit fonctionnel:

**Commande #11**

```
k get pod -l run=node --watch
```

- `-l run=node`: le se`l`ector pour l'image que la commande `kubectl run` a taggée pour nous
- `--watch`: la commande est automatiquement "rafraîchie"

**Résultat**

```
NAME   READY   STATUS         RESTARTS   AGE
node   0/1     ErrImagePull   0          4s
```

Diantre ! C'est un échec. Voyons pourquoi (`<Ctrl><C>`pour interrompre l'affichage):

**Commande #12**

```
k describe pod node
```

**Résultat (tronqué)**

```
 (...)
 Failed to pull image "uk.icr.io/k8s-lab/node-student": rpc error: code = Unknown desc = failed to pull and unpack image "uk.icr.io/k8s-lab/node-student:latest": failed to resolve reference "uk.icr.io/k8s-lab/node-student:latest": failed to authorize: failed to fetch anonymous token: unexpected status: 401 Unauthorized
 (...)
```

OK, en fait on aurait dû s'y attendre: on a dit que le registre était privé et on nous n'avons jamais renseigné de credentials ! 

Nous allons donc créer un "secret" spécifique (les secrets seront vus plus en détail dans le prochain training):

**Commande #13**

```
kubectl create secret docker-registry uk-icr-io --docker-server=uk.icr.io --docker-username=iamapikey --docker-email=iamapikey --docker-password=**API_KEY**
```

(remplacez `**API_KEY**` par celle qui vous a été envoyée par mail).

**Résultat**

```
secret/uk-icr-io created
```

Nous allons maintenant re-créer le pod (rappelez-vous qu'il est "immutable" pour l'essentiel) en lui indiquant d'utiliser cette fois notre secret fraîchement créé:

**Commande #14**

```
kubectl delete pod node && kubectl run node --image=uk.icr.io/k8s-lab/node-$USER --overrides='{ "spec": { "imagePullSecrets": [{"name": "uk-icr-io"}] } }'
```

- `--overrides='{...}'`: le paramètre à modifier / créer dans le YAML / JSON de déploiement

**Résultat**

```
pod "node" deleted
pod/node created
```

Allons voir à quoi ressemble les informations de ce pod:

**Commande #15**

```
k get pod node -o yaml
```

**Résultat (tronqué)**

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
(...)
  containers:
  - image: uk.icr.io/k8s-lab/node-student
(...)
  imagePullSecrets:
  - name: uk-icr-io
(...)
```

On voit:

- l'image: `uk.icr.io/k8s-lab/node-student` (`latest`est implicite)
- le "pull secret" (en gros: les credentials qui nous permettent de "pull" l'image):  `uk-icr-io`

Plus qu'à attendre que le pod soit (enfin) prêt:

**Commande #16**

```
k get pod -l run=node --watch
```

**Résultat**

```
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-5c559d5697-482dn   1/1     Running             0          7h14m
nginx-deployment-5c559d5697-fqk5r   1/1     Running             0          7h14m
nginx-deployment-5c559d5697-tfmbr   1/1     Running             0          7h14m
node                                0/1     ContainerCreating   0          14s
node                                1/1     Running             0          25s
```

Ouf! Cette fois, on dirait bien que le pod s'est déployé! Exposons le en tant que service "Node Port":

**Commande #17**

```
k expose pod node --type=NodePort --port=3000
```

- `pod node`: on expose le pod `node`
- `--port=3000`: le port exposé par notre container était le `3000`

Vérifions notre Node Port:

**Commande #17**

```
k get services
```

**Résultat**

```
NAME             TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
nginx-nodeport   NodePort   172.21.144.16    <none>        80:30617/TCP     6h28m
node             NodePort   172.21.118.190   <none>        3000:30663/TCP   61s
```

Dans notre cas c'est donc le port `30663`. Vérifions en allant sur `http://**CLUSTER_BASE_URL**:**NODE_PORT**`: vous devriez voir:

```
Hello World from **VOTRE_NOM**!
```

Allez un peu de nettoyage pour finir:

**Commande #18**

```
k delete service/node && k delete pod/node && k delete secret/uk-icr-io
```

**Résultat**

```
service "node" deleted
pod "node" deleted
secret "uk-icr-io" deleted
```

