# Lab: le registre privé IBM Cloud

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

### Ici Frankfurt

On va se connecter à IBM Cloud, le temps du lab (l'`API_KEY` vous a -normalement- été fournie par email):

**Commande #6**

```
ibmcloud login --apikey **API_KEY** -r eu-de -g lab -c 0b5a00334eaf9eb9339d2ab48f7326b4
```

**Résultat**

```
API endpoint: https://cloud.ibm.com
Authenticating...
OK

Targeted account ACME (0b5a00334eaf9eb9339d2ab48f7326b4) <-> 393750

Targeted resource group lab

Targeted region eu-de


API endpoint:      https://cloud.ibm.com
Region:            eu-de
User:              first.lastname@fr.ibm.com
Account:           ACME (0b5a00334eaf9eb9339d2ab48f7326b4) <-> 393750
Resource group:    lab
CF API endpoint:
Org:
Space:
```

Nous allons utiliser un registre privé sur IBM Cloud hébergé à Frankfurt.

**Commande #7**

```
ibmcloud cr region-set eu-de
```

**Résultat**

```
The region is set to 'eu-central', the registry is 'de.icr.io'.

OK
```

Nous allons maintenant lancer le build de l'image:

**Commande #8**

```
docker build -t de.icr.io/lab-registry/node-${USER} --build-arg user=$USER .
```

- `de.icr.io`: le registre IBM Cloud (à Frankfurt donc)
- `lab-registry/`: notre "namespace" sur le registre IBM Cloud 

**Résultat**

```
[+] Building 1.4s (10/10) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 37B
 => [internal] load . dockerignore
 => => transferring context: 2B      
 => [internal] load metadata for docker.io/library/node:14     
 => [auth] library/node:pull token for registry-1.docker.io
 => [1/4] FROM docker.io/library/node:14@sha256:d82d512aec5de4fac53b92b2aa148948c2e72264d650de9e1570283d4f503dbe
 => [internal] load build context
 => => transferring context: 60B
 => CACHED [2/4] WORKDIR /usr/src/app
 => CACHED [3/4] COPY package*.json app.js ./
 => CACHED [4/4] RUN npm install
 => exporting to image
 => => exporting layers
 => => writing image sha256:889482bc292667647f00cd9b4d74ce76a37e3884e3795ee3487e64f56bc1f627
 => => naming to docker.io/lab-registry/node-user

OK
```

Poussons notre image sur le cloud IBM

**Commande #9**

```
docker push de.icr.io/lab-registry/node-${USER}
```

**Resultats**

```
Using default tag: latest
The push refers to repository [de.icr.io/lab-registry/node-lionelmace]
ffde200139d5: Preparing
b6137117ad5a: Preparing
bb2a2bba460b: Preparing
f13fb423faca: Preparing
72e196931421: Preparing
64c220e07117: Waiting
595dd2bd3de6: Waiting
371dda325867: Waiting
381f4f0a6ea8: Waiting
155c77c325cb: Waiting
4d19f53ef378: Waiting
d6dff9eed369: Waiting
unauthorized: The login credentials are not valid, or your IBM Cloud account is not active.
```

C'est normal. Il faut d'abord se connecter au registre.

**Commande #10**

```
ibmcloud cr login
```

**Résultat**

```
Logging 'docker' in to 'de.icr.io'...
Logged in to 'de.icr.io'.

OK
```

On est bien connecte. Relancons le push de l'image

**Commande #11**

```
docker push de.icr.io/lab-registry/node-${USER}
```

**Résultat**

```
Using default tag: latest
The push refers to repository [de.icr.io/lab-registry/node-lionelmace]
ffde200139d5: Pushed
b6137117ad5a: Pushed
bb2a2bba460b: Pushed
f13fb423faca: Pushed
72e196931421: Pushed
64c220e07117: Pushed
595dd2bd3de6: Pushed
371dda325867: Pushed
381f4f0a6ea8: Pushed
155c77c325cb: Pushed
4d19f53ef378: Pushed
d6dff9eed369: Pushed
latest: digest: sha256:772e025d88c42e56f59fe8385eaf6fe885fc48535a776514cdb998e5e7dde1c5 size: 2840
```

Vérifions que notre image est bien présente:

**Commande #12**

```
ibmcloud cr images --va --restrict lab-registry
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

**Commande #13**

```
ibmcloud cr va de.icr.io/lab-registry/node-lionelmace:latest
```

- `va`: `vulnerability` `a`dvisor

*Note: il peut être nécessaire de patienter quelques instants que le scan de l'image ait pû être fait sur IBM Cloud (vous aurez dans ce cas une erreur de type `BXNVA0009E`)*

**Résultat**

```
Checking security issues for 'de.icr.io/lab-registry/node-lionelmace:latest'...

Image 'de.icr.io/lab-registry/node-lionelmace:latest' was last scanned on Mon Nov 28 21:53:10 UTC 2022
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
```

En gros: il y a des problèmes liés à des certificats SSL sur notre image. Bon à savoir... comme nous n'avons pas défini de restriction de déploiement pour nos images, rien ne nous empêche d'aller plus loin.
