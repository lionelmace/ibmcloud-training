# Docker - Lab 6: Docker avancé

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

### Se connecter à un container

Il peut être utile de se connecter à un container et d'exécuter des commandes depuis ce container. Nous allons nous servir d'une image de jeu de sudoku.

**Commande**

```
docker run -d --name sudoku -p 80:3000 coldfix/sudoku
```

**Résultat**

```
Unable to find image 'coldfix/sudoku:latest' locally
latest: Pulling from coldfix/sudoku
5a3ea8efae5d: Pull complete
d231963abd7c: Pull complete
36cf0b0ffc6a: Pull complete
3dc6949c980f: Pull complete
276a558ab9c5: Pull complete
eb9a9fcf2538: Pull complete
Digest: sha256:66d379d38bc45ed0760fe249db6a41dd25be2cdcb7cc340ab7e391151df734cc
Status: Downloaded newer image for coldfix/sudoku:latest
8ff6bd338dfe2104762cdde5e1fbb3ebf3a9d70acde784eddd841784228d1b41
```

On peut donc se connecter à notre page web habituelle: http://votre.adresse.ip. Pas mal mais avec un fond rose ce serait tellement plus joli...

Connectons-nous maintenant à ce container:

**Commande**

```
docker exec -it --user root sudoku ash
```

- `-it`: on exécute cette commande en mode `i`ntercatif et avec un `t`erminal
- `--user root`: on veut se connecter en tant que root pour avoir (tous!) les droits
- `ash`: le fameux `a`lpine `sh`ell

**Résultat**

```
/sudoku # 
```

Nous voilà connecté à l'intérieur du container.

Nous allons apporter une petite modification au style de la page web (via le _CSS_).

**Commande**

```bash
sed -i '2c background-color: pink;' html/sudoku.css
```

- `sed`: une commande bien utile pour manipuler des fichiers
- `-i`: on remplace le contenu d'un fichier
- `'2c background-color: green;`: la `2`ème ligne est `c`hangée en `background-color: pink;`

Rafraîchissez la page web (au besoin en appuyant sur `<Shift>` en même temps qu'on rafraîchit): le fond est ... rose !

On peut maiuntenant se déconnecter du container avec:

**Commande**

```bash
exit
```

(on aurait pu aussi utiliser `<Ctrl><D>`).

### Utilisation de `docker commit`

Très content du look de notre nouveau site, on aimerait en faire une image et pouvoir la partager. On a vu que le `Dockerfile` est un bon moyen mais il en existe un autre: le `commit`. En fait Docker va modifier l'image d'un container à partir du container lui-même.

**Commande**

```
docker commit sudoku sfillabs/sudoku-de-**VOTRE NOM**:pink
```

- `sudoku`: le nom du container à partir duquel on souhaite créer l'image
- `sfillabs/sudoku:pink`: la nouvelle image `sfillabs/sudoku` avec le tag `pink`

**Résultat**

```
sha256:ce38f4e7b1ac2bd59be13ce27e76cdccae03abbdd9f4f7f9f59e2ee4ae453ca8
```

C'est le SHA de notre nouvelle image.

On peut maintenant publier cette image:

**Commande**

```
docker push sfillabs/sudoku-de-**VOTRE NOM**:pink
```

Note: vous pouvez utiliser un autre nom d'image.

**Résultat**

```
The push refers to repository [docker.io/sfillabs/sudoku]
5927a2cf1e65: Pushed
e477fdb2fb58: Mounted from coldfix/sudoku
2b7fc79032af: Mounted from coldfix/sudoku
b6ada7780fc1: Mounted from coldfix/sudoku
3c2406c2349e: Mounted from coldfix/sudoku
c219437341dd: Mounted from coldfix/sudoku
721384ec99e5: Mounted from coldfix/sudoku
pink: digest: sha256:fa505d7f6b1bb0987f4c7c2f987b558bb9a75770ce1cef8d501176e57059cde9 size: 1780
```

 ### Suspendre un container

Il peut être utile de mettre en container sur pause, par exemple pour tester les effets de l'indisponibilité d'un composant d'une solution.

**Commande**

```
docker pause sudoku
```

**Résultat**

```
sudoku
```

Votre page préférée n'est plus accessible: http://votre.adresse.ip

Pour le sortir de pause:

**Commande**

```
docker unpause sudoku
```

**Résultat**

```
sudoku
```

On peut à nouveau jouer au sudoku sur http://votre.adresse.ip !