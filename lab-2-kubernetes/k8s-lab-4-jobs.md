# Kubernetes - Lab 4: les jobs & single run

## Prereqs

Ces exercices sont prévus pour être exécutés sur les machines virtuelles conçues par IBM pour la série de formation Kubernetes.

Pour se connecter:

```bash
ssh **VOTRE PRENOM**@**ADRESSE_IP**
```

`**ADRESSE_IP**` étant l'adresse qui vous a été envoyée individuellement, ainsi que le mot de passe pour vous connecter.

## Lab

### Faisons le job

Nous allons créer un job à partir de l'image Docker `alpine`. Toujours du YAML...

**Commande #1**

```YAML
cd ~/k8s-labs/2-k8s-base/4-jobs
cat job.yaml
```

**Résultat**

```YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world
spec:
  template:
    spec:
      containers:
      - name: hello-world
        image: hello-world
      restartPolicy: Never
  backoffLimit: 3
```

Rien de bien sensationnel dans ce YAML:

- Le container ne doit jamais redémarrer en cas de crash (seuls `Never` et `OnFailure` sont autorisés pour un job).
- En cas d'échec, seules 3 nouvelles tentatives sont autorisées (c'est le `backoffLimit`)

 Voyons le job en action:

**Commande #2**

```
kubectl apply -f job.yaml
```

**Résultat**

```
job.batch/hello-world created
```

Voyons donc les jobs:

**Commande #3**

```
kubectl get jobs
```

**Résultat**

```
NAME          COMPLETIONS   DURATION   AGE
hello-world   1/1           3s         62s
```

Super. Le job a fonctionné, il a pris `3s` pour s'exécuter. Voyons les détails:

**Commande #4**

```
kubectl describe job hello-world
```

**Résultat**

```
Name:           hello-world
Namespace:      user
Selector:       controller-uid=f9626f35-d581-4c11-a614-0a69f2494e8e
Labels:         controller-uid=f9626f35-d581-4c11-a614-0a69f2494e8e
                job-name=hello-world
Annotations:    <none>
Parallelism:    1
Completions:    1
Start Time:     Mon, 14 Sep 2020 10:00:19 +0000
Completed At:   Mon, 14 Sep 2020 10:00:22 +0000
Duration:       3s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=f9626f35-d581-4c11-a614-0a69f2494e8e
           job-name=hello-world
  Containers:
   hello-world:
    Image:        hello-world
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From            Message
  ----    ------            ----   ----            -------
  Normal  SuccessfulCreate  7m27s  job-controller  Created pod: hello-world-cwxw2
```

Tout s'est passé comme prévu: le job s'est exécuté et terminé (avec succès).

Voyons maintenant les pods:

**Commande #5**

```
kubectl get pods -l job-name=hello-world
```

- `-l job-name=hello-world` le selector qui nous permet de ne voir que les pods reliés au job `hello-world`

**Résultat**

```
NAME                READY   STATUS      RESTARTS   AGE
hello-world-cwxw2   0/1     Completed   0          115s
```

Un pod (avec son nom bizarre), qui est terminé. Normal. Allez, pour le fun, allons voir les logs de ce pod:

**Commande #6**

```
k logs hello-world-cwxw2
```

(remplacez `hello-world-cwxw2` par le nom de votre pod)

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

Tout va bien: c'est bien l'output de l'image Docker `hello-world` (de notre premier lab sur Docker !).

Nous allons maintenant créer un job qui ne se termine pas correctement (qui "fail"); pour cela nous allons éditer le YAML du job:

**Commande #7**

```
vi job.yaml
```

ou

```
nano job.yaml
```

Nous allons rajouter la ligne `command: ["sleep 3", "exit -1"]`  juste après `image: hello-world`:

```yaml
(...)        
        image: hello-world
        command: ["sleep 3", "exit -1"]
      restartPolicy: Never

```

Cette ligne subsituera la commande du container `hello-world` (qui affiche un message de bienvenue) par une pause de 3 secondes et le renvoi d'un code d'erreur (`-1`).

**Attention: l'alignement du texte est fondamental en YAML. `command:` doit être aligné sur `image:`**

Après sauvegarde du fichier, mettons à jour notre job:

**Commande #8**

```
kubectl apply -f job.yaml
```

**Résultat**

```
The Job "hello-world" is invalid: spec.template: Invalid value: core.PodTemplateSpec{ObjectMeta:v1.ObjectMeta{Name:"", GenerateName:"", Namespace:"", SelfLink:"", UID:"", ResourceVersion:"", Generation:0, CreationTimestamp:v1.Time{Time:time.Time{wall:0x0, ext:0, loc:(*time.Location)(nil)}}, DeletionTimestamp:(*v1.Time)(nil), DeletionGracePeriodSeconds:(*int64)(nil), Labels:map[string]string{"controller-uid":"f9626f35-d581-4c11-a614-0a69f2494e8e", "job-name":"hello-world"}, Annotations:map[string]string(nil), OwnerReferences:[]v1.OwnerReference(nil), Finalizers:[]string(nil), ClusterName:"", ManagedFields:[]v1.ManagedFieldsEntry(nil)}, Spec:core.PodSpec{Volumes:[]core.Volume(nil), InitContainers:[]core.Container(nil), Containers:[]core.Container{core.Container{Name:"hello-world", Image:"hello-world", Command:[]string{"sleep 3", "exit -1"}, Args:[]string(nil), WorkingDir:"", Ports:[]core.ContainerPort(nil), EnvFrom:[]core.EnvFromSource(nil), Env:[]core.EnvVar(nil), Resources:core.ResourceRequirements{Limits:core.ResourceList(nil), Requests:core.ResourceList(nil)}, VolumeMounts:[]core.VolumeMount(nil), VolumeDevices:[]core.VolumeDevice(nil), LivenessProbe:(*core.Probe)(nil), ReadinessProbe:(*core.Probe)(nil), StartupProbe:(*core.Probe)(nil), Lifecycle:(*core.Lifecycle)(nil), TerminationMessagePath:"/dev/termination-log", TerminationMessagePolicy:"File", ImagePullPolicy:"Always", SecurityContext:(*core.SecurityContext)(nil), Stdin:false, StdinOnce:false, TTY:false}}, EphemeralContainers:[]core.EphemeralContainer(nil), RestartPolicy:"Never", TerminationGracePeriodSeconds:(*int64)(0xc00e6b1970), ActiveDeadlineSeconds:(*int64)(nil), DNSPolicy:"ClusterFirst", NodeSelector:map[string]string(nil), ServiceAccountName:"", AutomountServiceAccountToken:(*bool)(nil), NodeName:"", SecurityContext:(*core.PodSecurityContext)(0xc012fe5110), ImagePullSecrets:[]core.LocalObjectReference(nil), Hostname:"", Subdomain:"", Affinity:(*core.Affinity)(nil), SchedulerName:"default-scheduler", Tolerations:[]core.Toleration(nil), HostAliases:[]core.HostAlias(nil), PriorityClassName:"", Priority:(*int32)(nil), PreemptionPolicy:(*core.PreemptionPolicy)(nil), DNSConfig:(*core.PodDNSConfig)(nil), ReadinessGates:[]core.PodReadinessGate(nil), RuntimeClassName:(*string)(nil), Overhead:core.ResourceList(nil), EnableServiceLinks:(*bool)(nil), TopologySpreadConstraints:[]core.TopologySpreadConstraint(nil)}}: field is immutable
```

En gros: un job est immuable (à peu près comme un pod). Une fois créé, on ne peut plus le modifier: il faut le détruire et le re-créer:

**Commande #9**

```
kubectl delete -f job.yaml && kubectl apply -f job.yaml
```

**Résultat**

```
job.batch "hello-world" deleted
job.batch/hello-world created
```

**Commande #10**

```
kubectl get jobs
```

**Résultat**

```
NAME          COMPLETIONS   DURATION   AGE
hello-world   0/1           58s        58s
```

Voilà; cette fois le job ne s'est pas exécuté avec succés. Voyons les détails:

**Commande #11**

```
watch -n 2 kubectl describe job hello-world
```

- `watch -n 2`: une commande bien utile pour relancer une même commande régulièrement et afficher ses résultats.

**Résultat**

(après une minute environ, les `Events` s'ajoutant au fur et à mesure jusqu'à ce que le `backoff limit` soit atteint):

```
Name:           hello-world
Namespace:      user
Selector:       controller-uid=ffa645b4-b703-47ff-90a3-656fab33f823
Labels:         controller-uid=ffa645b4-b703-47ff-90a3-656fab33f823
                job-name=hello-world
Annotations:    <none>
Parallelism:    1
Completions:    1
Start Time:     Mon, 14 Sep 2020 10:28:30 +0000
Pods Statuses:  1 Running / 0 Succeeded / 4 Failed
Pod Template:
  Labels:  controller-uid=ffa645b4-b703-47ff-90a3-656fab33f823
           job-name=hello-world
  Containers:
   hello-world:
    Image:      hello-world
    Port:       <none>
    Host Port:  <none>
    Command:
      sleep 3
      exit -1
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type     Reason                Age    From            Message
  ----     ------                ----   ----            -------
  Normal   SuccessfulCreate      2m57s  job-controller  Created pod: hello-world-98527
  Normal   SuccessfulCreate      2m55s  job-controller  Created pod: hello-world-7xkfq
  Normal   SuccessfulCreate      2m45s  job-controller  Created pod: hello-world-rrttq
  Normal   SuccessfulCreate      2m25s  job-controller  Created pod: hello-world-b8m4p
  Warning  BackoffLimitExceeded  105s   job-controller  Job has reached the specified backoff limit
```

L'information importante est là:

```
Pods Statuses:  1 Running / 0 Succeeded / 3 Failed
```

De même, remarquez la ligne:

```
  Warning  BackoffLimitExceeded  105s   job-controller  Job has reached the specified backoff limit
```

qui signifie en gros: "j'ai rééssayé autant de fois que demandé (2), ça marche pas, j'abandonne".

Pour interrompre l'affichage: `<Ctrl><C>`

Supprimons finalement ce job:

```
kubectl delete -f job.yaml
```

### Un job "périodique": le cron job

Le job ne s'exécute qu'une fois; un cas d'usage pourrait être le sauvegarde d'une base de données... et justement, si on veut faire un job programmé, qui se répéte ? Un peu comme un cron job Linux (pour les connaisseurs) ?

Justement, ça s'appelle un cron job (pour les curieux: ça vient du grec χρόνος qui veut dire... temps).

Voyons comment ça marche:

**Commande #12**

```
cat cronjob.yaml
```

**Résultat**

```YAML
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: say-time
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: alpine
            args:
            - /bin/ash
            - -c
            - echo "Time is $(date)"
          restartPolicy: OnFailure
```

- `schedule: "*/1 * * * *"` la fréquence d'exécution du job (voir par exemple: https://doc.ubuntu-fr.org/cron). Ici: toutes les minutes.

Allons-y:

**Commande #13**

```
k apply -f cronjob.yaml
```

**Résultat**

```
cronjob.batch/say-time created
```

Regardons les jobs se créer...

**Commande #14**

```
watch -n 2 kubectl get jobs
```

(après au moins une minute)

**Résultat**

```
Every 2.0s: kubectl get jobs                                                                                                                 

NAME                  COMPLETIONS   DURATION   AGE
say-time-1600097940   1/1           2s         40s
```

Toutes les minutes, un nouveau job est créé (`<Ctrl><C>` pour arrêter l'affichage).

On peut même voir les logs de ce cron:

**Commande #15**

```
kubectl logs -l job-name=say-time-1600098300
```

(remplacez `say-time-1600098300` par le nom d'un de vos jobs)

**Résultat**

```
Time is Mon Sep 14 15:45:05 UTC 2020
```

*Note: par défaut, seuls les 4 derniers jobs (et donc pods) d'un scheduled job sont conservés.*

On peut supprimer ce cron job fort inutile:

**Commande #16**

```
kubectl delete -f cronjob.yaml
```

**Résultat**

```
cronjob.batch "say-time" deleted
```

### L'init container

Nous allons donc créer un déploiement qui utilise un init container. Voyons à quoi ressemble le YAML:

**Commande #17**

```
cat initcontainer.yaml
```

**Résultat**

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: delayed-app
  labels:
    app: delayed-app
spec:
  containers:
  - name: nginx
    image: nginx:alpine
  initContainers:
  - name: wait-a-little
    image: alpine
    command: ['ash', '-c', 'echo "Sleeping"; sleep 45; echo "Done"']
  - name: wait-a-little-more
    image: alpine
    command: ['ash', '-c', 'echo "Sleeping"; sleep 60; echo "Done"']
```

- `command: ['ash', '-c', 'echo "Sleeping"; sleep 45; echo "Done"']`: on peut mixer du YAML et du JSON !

Créons notre pod:

**Commande #18**

```
kubectl create -f initcontainer.yaml
```

**Résultat**

```
pod/delayed-app created
```

Pour bien apprécier ce qui se passe, nous allons recourir à un petit outil bien sympathique: Stern. Stern nous permet ici de voir les logs de tous les containers de notre pod en temps réél:

**Commande #19**

```
stern delayed-app
```

- `delayed-app`: le nom de notre pod, mais on verra qu'on peut lui donnere aussi le nom d'un deployment, d'un statefulset etc...

**Résultat**

```
+ delayed-app › wait-a-little
delayed-app wait-a-little Sleeping
delayed-app wait-a-little Done
+ delayed-app › wait-a-little-more
delayed-app wait-a-little-more Sleeping
delayed-app wait-a-little-more Done
+ delayed-app › nginx
delayed-app nginx /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
delayed-app nginx /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
delayed-app nginx /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
delayed-app nginx 10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
delayed-app nginx 10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
delayed-app nginx /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
delayed-app nginx /docker-entrypoint.sh: Configuration complete; ready for start up
```

On observe en temps réél:

- Le démarrage du container `wait-a-little`, puis sa fin (45 secondes après)
- Le démarrage du container `wait-a-little-more`, puis sa fin (60 secondes après)
- Finalement le démarrage du container `nginx` !

On interrompt l'affichage avec `<Ctrl><C>`.

On peut maintenant supprimer ce pod:

**Commande #20**

```
kubectl delete -f initcontainer.yaml
```

**Résultat**

```
pod "delayed-app" deleted
```

