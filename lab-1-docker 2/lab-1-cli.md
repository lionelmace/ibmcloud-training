# Docker - Lab 1: Docker CLI

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

Nous allons pour commencer exécuter la commande qui permet de vérifier que Docker est bien installé:

### Hello world !

**Commande**

```
docker run hello-world
```

**Résultat**

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:4cf9c47f86df71d48364001ede3a4fcd85ae80ce02ebad74156906caff5378bc
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Nous aurons l'occasion de revenir en détail sur ce que cette commande a effectué. Pour l'instant, contentons-nous du résultat !

### Quelques commandes...

Voyons la liste des images présentes localement:

**Commande**

```
docker images
```

**Résultat**

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        8 months ago        13.3kB
```

On voit que l'image du container `hello-world` est présente. Rien de bien surprenant: on vient d'exécuter le container, donc la première étape a consisté à télécharger l'image localement.

Voyons ensuite quels containers sont actifs:

**Commande**

```
docker ps
```

**Résultat**

```
CONTAINER ID    IMAGE           COMMAND         CREATED         STATUS          PORTS           NAMES
```

En gros: rien. Normal: le container `hello-world` n'est pas un "daemon": il affiche un message puis se termine; c'est pourquoi il n'est pas actif.

Justement, voyons maintenant *tous* les containers (y compris les terminés / inactifs):

**Commande**

```
docker ps -a
```

**Résultat**

```
CONTAINER ID    IMAGE        COMMAND     CREATED         STATUS                   PORTS    NAMES
41676bc83e2c    hello-world  "/hello"    6 minutes ago   Exited (0) 6 minutes ago          practical_tereshkova
```

Le container `hello-world` est effectivement terminé. Comme on ne lui a pas donné de nom, il a un nom "aléatoire" (ici: `practical_tereshkova`) et n'expose pas de port.

Voyons les logs de ce container:

**Commande**

```
docker logs **VOTRE NOM DE CONTAINER**
```

**Résultat**

```

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Regardons pour finir les réseaux qui existent par défault:

**Commande**

```
docker network ls
```

**Résultat**

```
NETWORK ID          NAME                DRIVER              SCOPE
cbe470dbc703        bridge              bridge              local
e81165463863        host                host                local
b3fc97a74e40        none                null                local
```

Il y a trois réseaux disponibles. Nous verrons cela plus tard.





