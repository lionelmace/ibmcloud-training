# Docker - Lab 2: Les images Docker

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Construire (et exécuter) sa propre image

Nous avons vu que la façon la plus "courante" pour construire un image Docker était de partir d'une `Dockerfile`. Voyons cela:

**Commande**

```bash
cd k8s-labs/1-docker/2-images
cat Dockerfile
```

**Résultat**

```Dockerfile
FROM alpine:latest
RUN echo "This is build time"
# Pour les plus téméraires (!) changer la valeur de la variable user
ENV user "SFIL USER"
RUN touch /a_new_file
CMD echo "This is runtime: hello from $user"
```

Ce Dockerfile contient 5 lignes:

- Ligne 1: `FROM alpine:latest` l'image de base (Alpine Linux est un Linux "light" très utilisé pour les images Docker)
- Ligne 2: `RUN echo "This is build time"` cette exécution est effectuée lors de la construction de l'image
- Ligne 3: un commentaire 🙄
- Ligne 4: `ENV user "SFIL USER"` on définit une variable (`user`) et on lui assigne une valeur
- Ligne 5: `RUN touch /a_new_file` on crée un fichier (vide)
- Ligne 5: `CMD echo "This is runtime: hello from $user"` on définit **le** process Docker (ici: on affiche un message et on s'arrête)

Nous allons maintenant construire l'image correspondante à ce magnifique `Dockerfile`:

**Commande**

```
docker build -t monimage .
```

- `build`: on veut construire l'image
- `-t mon image`: on veut l'appeler `monimage`
- `.`: le "folder" à partir duquel cette image doit être construite. L'intégralité du contenu de ce folder sera transmis au Docker daemon

**Résultat**

```
Sending build context to Docker daemon  2.048kB
Step 1/5 : FROM alpine:latest
latest: Pulling from library/alpine
df20fa9351a1: Pull complete
Digest: sha256:185518070891758909c9f839cf4ca393ee977ac378609f700f60a771a2dfe321
Status: Downloaded newer image for alpine:latest
 ---> a24bb4013296
Step 2/5 : RUN echo "This is build time"
 ---> Running in 9f35bac0f87e
This is build time
Removing intermediate container 9f35bac0f87e
 ---> 67af40db71ea
Step 3/5 : ENV user "SFIL USER"
 ---> Running in 49850b30f4f0
Removing intermediate container 49850b30f4f0
 ---> ce71a38f5189
Step 4/5 : RUN touch /a_new_file
 ---> Running in 9f28e6f8ef1e
Removing intermediate container 9f28e6f8ef1e
 ---> 84eae78f294e
Step 5/5 : CMD echo "This is runtime: hello from $user"
 ---> Running in de41000baf66
Removing intermediate container de41000baf66
 ---> f4dce77a0636
Successfully built f4dce77a0636
Successfully tagged monimage:latest
```

À noter:

- la commande `echo "This is build time"` *est* exécutée
- la commande  `echo "This is runtime: hello from $user"` *n'est pas* exécutée

Vérifions que la commande est bien présente localement:

**Commande**

```
docker images
```

**Résultat**

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
monimage            latest              f4dce77a0636        2 minutes ago       5.57MB
alpine              latest              a24bb4013296        3 months ago        5.57MB
hello-world         latest              bf756fb1ae65        8 months ago        13.3kB
```

Elle est bien là! Et avec elle, l'image "de base" de notre image: `alpine`. Nous verrons plus tard la notion de tag (`latest` ici).

Exécutons maintenant cette image (= créons le container )

**Commande**

```
docker run --name moncontainer monimage
```

- `run`: exécution d'un container
- `--name moncontainer`:  le nom du container
- `monimage`: l'image du container

**Résultat**

```
This is runtime: hello from **someone ou la valuer modifiée**
```

Voilà... cette fois la commande s'est exécutée. On peut vérifier la liste des containers:

**Commande**

```
docker ps -a
```

**Résultat**

```
CONTAINER ID  IMAGE       COMMAND             CREATED         STATUS                    NAMES
e2499664e522  monimage    "/bin/sh -c 'echo…" 21 minutes ago  Exited (0) 21 minutes ago moncontainer
41676bc83e2c  hello-world "/hello"            55 minutes ago  Exited (0) 44 minutes ago practical_tereshkova
```

Elle est là! Et avec son vrai nom cette fois (`moncontainer`)

### Tagger et publier son image

Cette magnifique image que nous venons de builder, nous allons la publier sur le repository "public" de Docker: le "Docker Hub".

Un "registry" existe déjà: https://hub.docker.com/u/sfillabs. Il ne contient pas grand chose pour l'instant mais devrait se remplir grâce à cet exercice...

Commençons par nous connecter au repository:

**Commande**

```
docker login -u sfillabs -p sfillabsRgr8
```

- `login`: on se connecte à Docker Hub
- `-u sfillabs`: l'utilisateur
- `-p sfillabsRgr8`: le mot de passe

**Résultat**

```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/sfil/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Bon ne faisons pas attention aux avertissements, on a passé un mot de passe en ligne de commande et c'est pas très bien... mais ce n'est qu'un exercice !

Essayons maintenant de publier notre image:

**Commande**

```
docker push monimage
```

**Résultat**

```
The push refers to repository [docker.io/library/monimage]
dc8159062f58: Preparing
50644c29ef5a: Preparing
denied: requested access to the resource is denied
```

Cuisant échec ! Ce que la CLI ne nous dit pas c'est pourquoi (et c'est dommage). En fait la raison c'est que pour pouvoir pousser sur le Docker Hub, il faut que l'image contienne le chemin du nom du registre, ici `sfillabs/`.

Nous allons donc "tagger" notre image avec ce préfixe:

```
docker tag monimage sfillabs/image-de-**VOTRE NOM**
```

par exemple:

**Commande**

```
docker tag monimage sfillabs/image-d-eric
```

- `tag`: on tag une image
- `monimage`: l'image que l'on souhaite tagger
- `sfillabs/image-d-eric`: le tag à ajouter

On peut vérifier:

**Commande**

```
docker images
```

**Résultat**

```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
monimage                   latest              f4dce77a0636        47 minutes ago      5.57MB
sfillabs/image-d-eric      latest              f4dce77a0636        47 minutes ago      5.57MB
alpine                     latest              a24bb4013296        3 months ago        5.57MB
hello-world                latest              bf756fb1ae65        8 months ago        13.3kB
```

Même si on a l'impression d'une image supplémentaire, c'est bien la même image qui porte deux tags (l'id est le même).

On peut re-pousser l'image:

**Commande**

```
docker push sfillabs/image-de-**VOTRE NOM**
```

**Résultat**

```
The push refers to repository [docker.io/sfillabs/image-d-eric]
a9926823dc3b: Pushed
50644c29ef5a: Pushed
latest: digest: sha256:e74842f39546d4b79f4737080bdb48ae14b8e09ce33ef97d1be9995ae3786a7f size: 734
```

Cette fois, succès! 

On peut même vérifier: https://hub.docker.com/u/sfillabs