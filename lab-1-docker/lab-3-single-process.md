# Docker - Lab 3: Le "single process"

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Nginx (engine-x)

Pour ce lab, nous allons utiliser une image d'un soft très populaire: Nginx. Nginx est un serveur HTTP très performant et peu consommateur de ressources.

**Commande**

```
docker run --name nginx -p 80:80 nginx:alpine
```

- `-p 80:80`: on expose au niveau de l'hôte le port 80 qui est mappé sur le port 80 du container.
- `nginx:alpine`: on veut l'image taggée `alpine` de  `nginx`.

**Résultat**

```
Unable to find image 'nginx:alpine' locally
alpine: Pulling from library/nginx
df20fa9351a1: Already exists
3db268b1fe8f: Pull complete
f682f0660e7a: Pull complete
7eb0e8838bc0: Pull complete
e8bf1226cc17: Pull complete
Digest: sha256:a97eb9ecc708c8aa715ccfb5e9338f5456e4b65575daf304f108301f3b497314
Status: Downloaded newer image for nginx:alpine
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

Et le ligne de commande ne nous rend pas la main ! Pas très pratique... on va donc arrêter le container (`Ctrl-C`) et le supprimer:

**Commande**

```
docker rm nginx
```

**Résultat**

```
nginx
```

ça peut paraître bizarre... mais cela permet de chaîner les commandes.

On relance notre container en mode "daemon":

**Commande**

```
docker run -d --name nginx -p 80:80 nginx:alpine
```

**Résultat**

```
99441e450a78a41204ddfb471b1cd8a02b45369fca612339388226931582d752
```

C'est l'id complet du container.

Vérifions que notre container fonctionne:

**Commande**

```
docker ps
```

**Résultat**

```
CONTAINER ID  IMAGE         COMMAND        CREATED              STATUS              PORTS      NAMES
99441e450a78  nginx:alpine  "/docker-en…"  About a minute ago   Up About a minute   80/tcp     nginx
```

Ouf, tout va bien. Vous pouvez (normalement) accéder à: http://votre.adresse.ip.

### Le pid "1"

Dans le container, le process "principal" ("single process") a toujours le PID 1. On va le vérifier.

**Commande**

```
docker exec nginx ps -e
```

- `exec`: exécuter une commande dans un container actif
- `nginx`: le nom du container
- `ps -e`: la commande à exécuter

**Résultat**

```
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
   31 nginx     0:00 nginx: worker process
   32 nginx     0:00 nginx: worker process
   45 root      0:00 ps -e
```

On voit le process avec le PID `1`, qui a été exécuté en tant que `root` et qui a manifestement conduit à la création de deux processes "fils" (exécutés en tant que `nginx`)

Par cutiosité, regardons maintenant les processes `nginx` de la machine hôte:

**Commande**

```
root     11035 11013  0 11:53 ?        00:00:00 nginx: master process nginx -g daemon off;
systemd+ 11107 11035  0 11:53 ?        00:00:00 nginx: worker process
systemd+ 11108 11035  0 11:53 ?        00:00:00 nginx: worker process
```

Incroyable: on retrouve nos mêmes 3 processes avec un id différent !

Cela est tout à fait normal: Docker *n'est pas* une machine virtuelle donc un process dans un container = un process sur la machine hôte. Voilà une des premières limites de l'isolation "limitée" de Docker.

On va mantenant "tuer" process depuis le container:

**Commande**

```
docker exec nginx kill -15 1
```

- `kill -15 1`: on "termine" le process avec l'ID 1

Vérifions où en est notre process:

**Commande**

```
docker ps -a
```

**Résultat**

```
CONTAINER ID   IMAGE          COMMAND                   CREATED          STATUS                    NAMES
9d07e5a7b4ed   nginx:alpine   "/docker-entrypoint.…"    16 seconds ago   Exited (0) 3 seconds ago  nginx
(...)
```

Le container est bien arrêté (`Exited ...`). D'ailleurs on ne peut plus accéder à la page: http://votre.adresse.ip

On peut (heureusement) facilement le relancer:

**Commande**

```
docker start nginx
```

**Résultat**

```
nginx
```

Puis vérifions qu'il est bien fonctionnel:

**Commande**

```
docker ps
```

**Résultat**

```
CONTAINER ID  IMAGE         COMMAND                 CREATED        STATUS        PORTS                NAMES
9d07e5a7b4ed  nginx:alpine  "/docker-entrypoint.…"  3 minutes ago  Up 4 seconds  0.0.0.0:80->80/tcp   nginx
```

Il est bien là ! Et on peut même vérifier qu'il marche bien:  http://votre.adresse.ip