# Docker - Lab 4: Les volumes

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Nginx (engine-x) ... encore !

Commençons par supprimer une éventuelle instance de container Nginx:

**Commande**

```
docker rm -f nginx
```

- `rm -f nginx`: on force la suppression du container `nginx`, même s'il est en train de s'exécuter

**Résultat**

```
nginx
```

Nous allons maintenant remplacer la page d'accueil HTML par une page personnalisée. Pour cela, nous allons utiliser un "bind mount" vers un dossier à nous.

**Commande**

La premiere etape est de creer la nouvelle page HTML

```bash
touch index.html
```

Editer ce fichier pour y ajouter ce contenu

```html
<H1>Hello from IBM Garage for Cloud !</H1>
```

Les plus audacieux pourront personnaliser cette page ...

Nous allons maintenant créer un container qui utilise cette page grâce à un volume:

**Commande**

```
docker run -d --name nginx -p 80:80 -v ~/k8s-labs/1-docker/4-volumes:/usr/share/nginx/html:ro nginx:alpine
```

- `-v ~/k8s-labs/1-docker/4-volumes:/usr/share/nginx/html:ro`: nous "montons" un dossier de la machine hôte (`~/k8s-labs/1-docker/4-volumes`) dans le container (sur `/usr/share/nginx/html`) en lecture seule ( `ro`)

**Résultat**

```
628dd8e5d7405cf660022dedac569075b3eb0653d839a17a204f1874be79baae
```

L'ID du container.

Vérifions notre page web en allant sur http://votre.adresse.ip. On peut aussi tester utiliser `curl localhost`:

**Résultat**

```html
<H1>Hello from IBM Garage for Cloud !</H1>
```

Ça marche on dirait ! on peut même changer le contenu à la volée:

**Commande**

```
echo "<H1>Issa Nissa</H1>" > ~/k8s-labs/1-docker/4-volumes/index.html
```

Puis rééssayons de nous connecter sur http://votre.adresse.ip (ou `curl localhost`), le message a bien changé !

**Résultat**

```html
<H1>Issa Nissa</H1>
```

On peut même arrêter le container:

**Commande**

```
docker stop nginx
```

**Résultat**

```
nginx
```

Et modifier à nouveau notre contenu:

**Commande**

```
echo "<H1>I've been modified while container was not there</H1>" > ~/k8s-labs/1-docker/4-volumes/index.html
```

et finalement démarrer le container:

**Commande**

```
docker start nginx
```

**Résultat**

```
nginx
```

Puis si on se connecte sur http://votre.adresse.ip (ou `curl localhost`), le message est comme attendu:

**Résultat**

```html
<H1>I've been modified while container was not there</H1>
```

