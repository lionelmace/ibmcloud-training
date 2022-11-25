# Kubernetes - Lab 1: Kubernetes et CLIs

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Connexion à IBM Cloud

On va se connecter à IBM Cloud, le temps du lab (l'`API_KEY` vous a -normalement- été fournie par email):

**Commande #1**

```
ibmcloud login --apikey **API_KEY** -r eu-de -g BSC-Garage -c c7ab6a05ec1e3eb13f5e81aa302bdbd0
```

**Résultat**

```
API endpoint: https://cloud.ibm.com
Authenticating...
OK

Targeted account CPL@fr ibm com's Account (c7ab6a05ec1e3eb13f5e81aa302bdbd0) <-> 393750

Targeted resource group BSC-Garage

Targeted region eu-de


API endpoint:      https://cloud.ibm.com
Region:            eu-de
User:              nicolas.comete@fr.ibm.com
Account:           CPL@fr ibm com's Account (c7ab6a05ec1e3eb13f5e81aa302bdbd0) <-> 393750
Resource group:    BSC-Garage
CF API endpoint:
Org:
Space:
```

Et on va aussi se connecter à notre cluster:

**Commande #2**

```
ibmcloud ks cluster config --cluster **CLUSTER_NAME**
```

Le `CLUSTER_NAME` vous a également été transmis par mail.

### Quelques aliases... et de l'autocompletion !

Pour les labs à venir, votre VM dispose de 3 aliases utiles:

- `k` pour `kubectl`
- `i` pour `ibmcloud`
- `d` pour `docker`

Par ailleurs, la commande `kubectl` (tout comme son alias `k`) dispose de l'autocomplétion: un appui sur `<Tab>` pour mle début d'une commande ou d'un item permet la complétion automatique.

### Chacun chez soi

Pour ce lab, la configuration pour la ligne de commande `kubectl` devrait déjà être faite pour se connecter au cluster Kubernetes créé sur IBM Cloud (et qui sera partagé par tous les participants). 

Nous allons commencer par créer un namespace dans lequel vont se dérouler les différents labs:

**Commande #3**

```
kubectl create namespace $USER
```

**Résultat**

```
namespace/student created
```

Note: évidemment le nom de votre namespace dépendra de votre identifiant pour ce lab.

Maintenant que ce namespace est créé, nous allons maintentant indiquer que nous souhaitons l'utiliser:

**Commande #4**

```
kubectl config set-context --current --namespace=$USER 
```

**Résultat**

```
Context "k8s-training-comete/btgclpuf0ma5t7n63srg" modified.
```

### Configuration du cluster

Regardons maintenant les détails de notre cluster:

**Commande #5**

```
kubectl get nodes
```

- `get`: permet de recupérer des information (sommaires) sur un ou plusieurs objets Kubernetes

**Résultat**

```
NAME           STATUS   ROLES    AGE   VERSION
10.126.98.82   Ready    <none>   18h   v1.17.11+IKS
10.126.98.83   Ready    <none>   18h   v1.17.11+IKS
```

Voilà... 2 worker nodes, qui sont prêts. On peut avoir plus de détails:

**Commande #6**

```
kubectl get nodes -o wide
```

**Résultat (tronqué)** 

```
NAME           STATUS   ROLES    AGE   VERSION        INTERNAL-IP    EXTERNAL-IP
10.126.98.82   Ready    <none>   18h   v1.17.11+IKS   10.126.98.82   159.8.124.212
10.126.98.83   Ready    <none>   18h   v1.17.11+IKS   10.126.98.83   159.8.124.217
```

Toujours avec un `get`, on peut aussi récupérer les détails d'un worker node spécifiquement:

**Commande #7**

```
kubectl get node 10.126.98.82
```

**Résultat**

```
NAME           STATUS   ROLES    AGE   VERSION
10.126.98.82   Ready    <none>   18h   v1.17.11+IKS
```

On peut également regarder les détails d'un worker node avec la commande `describe`:

**Commande #8**

```
kubectl describe node 10.126.98.82
```

**Résultat (tronqué)**

Plusieurs lignes méritent un interêt:

- *Conditions*:

```
Conditions:
  Type      Status  LastHeartbeatTime          LastTransitionTime       Reason         Message
  ----      ------  -----------------          ------------------       ------         -------
  ...       ...     ...                        ...                      ...            ...
```

Ces lignes nous donnent l'état de santé du worker node (mémoire, disque et process IDs). 

- *Non-terminated Pods*:

```
  Namespace    Name                       CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------    ----                       ------------  ----------  ---------------  -------------  ---
  ibm-system   addon-catalog-source-nrzr2 10m (0%)      100m (5%)   50Mi (1%)        100Mi (3%)     73m
  ...          ...                        ...           ...         ...              ...            ...

```

En gros, les pods (=les runtimes) qui sont actifs et ce qu'ils consomment.

- *Allocated resources*:

```
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests        Limits
  --------           --------        ------
  cpu                749m (39%)      548m (28%)
  memory             946706Ki (32%)  5390624Ki (184%)
  ephemeral-storage  0 (0%)          0 (0%)
  hugepages-1Gi      0 (0%)          0 (0%)
  hugepages-2Mi      0 (0%)          0 (0%)
```

Le total des ressources consommées... on constate que sur un cluster "vierge", en gros 1Go de RAM est déjà utilisé (par la gestion des ressources, sécurité, DNS etc..).

Pour terminer, voyons un peu les "pods" actifs sur tous les namespaces:

**Commande #9**

```
k get pods --all-namespaces
```

-`k`: notre alias - voir plus haut ...

**Résultat**

```
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
ibm-system    addon-catalog-source-txwl7                            1/1     Running   0          18h
ibm-system    catalog-operator-67646bfcdb-6jpt8                     1/1     Running   0          18h
ibm-system    ibm-cloud-provider-ip-159-8-90-131-765c57d585-jtkpf   1/1     Running   0          18h
ibm-system    ibm-cloud-provider-ip-159-8-90-131-765c57d585-tdgff   1/1     Running   0          18h
ibm-system    olm-operator-787498c9b7-nxnn2                         1/1     Running   0          18h
kube-system   calico-kube-controllers-5754cfb59d-qsmtd              1/1     Running   0          18h
kube-system   calico-node-5b547                                     1/1     Running   0          18h
kube-system   calico-node-68kjs                                     1/1     Running   0          18h
kube-system   coredns-6567db4fff-7pn7c                              1/1     Running   0          18h
kube-system   coredns-6567db4fff-bfzg7                              1/1     Running   0          18h
kube-system   coredns-6567db4fff-ljnxb                              1/1     Running   0          18h
kube-system   coredns-autoscaler-649976fbf4-7qx8v                   1/1     Running   0          18h
kube-system   dashboard-metrics-scraper-5789d44f58-tqgrb            1/1     Running   0          18h
kube-system   ibm-file-plugin-5c88c696c5-zhvm8                      1/1     Running   0          18h
kube-system   ibm-keepalived-watcher-f8sh4                          1/1     Running   0          18h
kube-system   ibm-keepalived-watcher-qd2sw                          1/1     Running   0          18h
kube-system   ibm-master-proxy-static-10.126.98.82                  2/2     Running   0          18h
kube-system   ibm-master-proxy-static-10.126.98.83                  2/2     Running   0          18h
kube-system   ibm-storage-watcher-554b77cb7c-kwtff                  1/1     Running   0          18h
kube-system   kubernetes-dashboard-984c5c57-nk5w2                   1/1     Running   0          18h
kube-system   metrics-server-59d48bc8db-2pbx9                       2/2     Running   0          18h
kube-system   public-crbtgclpuf0ma5t7n63srg-alb1-69b57866d9-6lzs6   4/4     Running   0          18h
kube-system   public-crbtgclpuf0ma5t7n63srg-alb1-69b57866d9-9sql9   4/4     Running   0          18h
kube-system   vpn-f66c45467-9s8f7                                   1/1     Running   0          18h
```

On voit qu'on certain nombre de pods existent sur notre cluster avant même que l'on ait commencé à s'en servir !