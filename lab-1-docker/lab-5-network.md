# Docker - Lab 5: les "networks"

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Cleanup time

Commençons par supprimer tous les containers:

**Commande**

```
docker rm -f $(docker ps -qa)
```

- `$(docker ps -qa)`: récupération des IDs de tous les containers en format "court"

**Résultat**

```
51a5cc2e0c58
a2f89779ce46
d84129611008
```

Les IDs de tous les containers supprimés.

### Notre réseau !

Commençons par créer un réseau "maison":

**Commande**

```
docker network create --driver bridge wp-net
```

- `--driver bridge`: on utilise le type "bridge"

**Résultat**

```
1f662e97f4656777896d0a77841052e597dd731bc40c41c495e172b9f7da4e83
```

L'ID du réseau que l'on vient de créer.

### Wordpress et MySQL

Wordpress est une plateforme de blogging open source très populaire qui a besoin pour fonctionner d'une base données; ici nous allons utiliser MySQL et faire communiquer ces deux containers via un réseau dédié.

Commençons par le container MySQL:

**Commande**

```
docker run --name mysql -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=mot2pass -e MYSQL_RANDOM_ROOT_PASSWORD=yes --net wp-net -d mysql
```

- `-e **NOM**=**VALEUR**`: permet de passer des paramètres à notre container MySQL
- `--net wp-net`: on utilise notre nouveau réseau

**Résultat**

```
Unable to find image 'mysql:latest' locally
latest: Pulling from library/mysql
d121f8d1c412: Pull complete
f3cebc0b4691: Pull complete
1862755a0b37: Pull complete
489b44f3dbb4: Pull complete
690874f836db: Pull complete
baa8be383ffb: Pull complete
55356608b4ac: Pull complete
dd35ceccb6eb: Pull complete
429b35712b19: Pull complete
162d8291095c: Pull complete
5e500ef7181b: Pull complete
af7528e958b6: Pull complete
Digest: sha256:e1bfe11693ed2052cb3b4e5fa356c65381129e87e38551c6cd6ec532ebe0e808
Status: Downloaded newer image for mysql:latest
5d55f178f63e16a8611554239ef5be5edfd1c10ee2faac888392294dc226d201
```

Vérifions que notre base est fonctionnelle:

**Commande**

```
docker logs mysql
```

**Résultat**

```
(...)
2020-09-10 14:43:44+00:00 [Note] [Entrypoint]: MySQL init process done. Ready for start up.

2020-09-10T14:43:44.837552Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.21) starting as process 1
2020-09-10T14:43:44.845527Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2020-09-10T14:43:45.057633Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2020-09-10T14:43:45.141789Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
2020-09-10T14:43:45.196642Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
2020-09-10T14:43:45.196794Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
2020-09-10T14:43:45.199370Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
2020-09-10T14:43:45.214277Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.21'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
```

Voilà. En quelques secondes nous avons une base de données prête à être utilisée !

Créons maintenant notre container Wordpress:

**Commande**

```
docker run --name wordpress --net wp-net -d -p 80:80 wordpress
```

**Résultat**

```Unable to find image 'wordpress:latest' locally
latest: Pulling from library/wordpress
bf5952930446: Already exists
a409b57eb464: Pull complete
3192e6c84ad0: Pull complete
43553740162b: Pull complete
d8b8bba42dea: Pull complete
eb10907c0110: Pull complete
10568906f34e: Pull complete
ea72c5f3651b: Pull complete
5adcd0c0ecc3: Pull complete
3223d70e4296: Pull complete
5fb31eed71d2: Pull complete
5dd4ab964294: Pull complete
6bd3f1cf7584: Pull complete
9d13d643694e: Pull complete
68dfee003196: Pull complete
80d270753507: Pull complete
99d8ac9072c0: Pull complete
03c4290b000d: Pull complete
bae55e72a55e: Pull complete
c6358170f905: Pull complete
Digest: sha256:44606029218d6a6fdd7c98520b14ff1a738b155a4cd7f14b49451ae4eca49e2b
Status: Downloaded newer image for wordpress:latest
df1fa796ad015159267d669a71a7e1e888a544932e9a392619547e7ca3455718
```

Et voilà: notre Wordpress est (presque) prêt... il reste à le configurer. Pour cela, il faut accéder à http://votre.adresse.ip.

- Choisir la langue
- Puis dans la page de configuration de la base de données:
  - Database name: `wordpress`
  - Username: `wordpress`
  - Password: `mot2pass`
  - Database Host: `mysql`
  - Table Prefix: `wp_`
- Vous pouvez ensuite personnaliser votre Wordpress comme bon vous semble, par exemple:
  - Site Title: `Test k8s`
  - Username: `someone`
  - Password: `m0t2pass3`
  - Your email: `a@b.com`
- Vous pouvez vous connecter avec:
  - Username: `someone`
  - Password: `m0t2pass3`

Votre Wordpress est pleinement fonctionnel !