# Deploy an Application with a Persistence Volume

## Pre-Requisites

  * Install Infrastructure Service plugin `ibmcloud plugin install infrastructure-service`
  * Install OpenShift Command Line

## Deploy the app and the volume

1. Deploy a Persistence Volume Claim.

    ```bash
    oc apply -f - <<EOF
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: test-claim
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 20Mi
      storageClassName: ibmc-vpc-block-general-purpose
    EOF
    ```

1. View the PVC

    ```bash
    oc get pvc
    ```

    Output:

    ```
    NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                     AGE
    test-claim   Bound    pvc-89527180-e2a9-4496-877a-ccb8fccbf123   10Gi       RWO            ibmc-vpc-block-general-purpose   6m26s
    ```

    > Notice that the PVC is bound to a dynamically created volume.

1. View the persistent volume

    ```bash
    oc get pv $(oc get pvc |  awk 'NR>1 {print $3}')
    ```

    Output:

    ```
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS                     REASON   AGE
    pvc-89527180-e2a9-4496-877a-ccb8fccbf123   10Gi       RWO            Delete           Bound    lab-mace/test-claim   ibmc-vpc-block-general-purpose            18m
    ```

1. View the volume in VPC Block Storage in

    ```sh
    ibmcloud is vols
    ```

    > The volume is also visible in the console at [VPC Block storage volumes](https://cloud.ibm.com/vpc-ext/storage/storageVolumes)

1. Deploy the application using this pvc

    ```bash
    oc apply -f - <<EOF         
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: test-volume
    spec:
      containers:
      - name: test-odf
        image: nginx
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo $(date -u) >> /test/test.txt; sleep 600; done"] 
        volumeMounts:
        - name: persistent-storage
          mountPath: "/test"
      restartPolicy: "Never"
      volumes:
        - name: persistent-storage
          persistentVolumeClaim:
            claimName: test-claim
    EOF
    ```

    The output will be similar to

    ```bash
    persistentvolumeclaim/test-claim created
    pod/test-pod created
    ```

1. To verify that the pod is deployed, wait for your app to get into a Running status.

    ```bash
    oc get pod test-volume
    ```

    Example outputs:

    ```
    oc get pod test-volume
    NAME          READY   STATUS    RESTARTS   AGE
    test-volume   1/1     Running   0          31s  
    ```

1. Verify that the app can write data. Log in to your pod.

    ```sh
    oc exec test-volume -it -- bash
    ```

1. Display the contents of the test.txt file to confirm that your app can write data to your persistent storage.

    ```sh
    cat /test/test.txt
    ```

    Example output

    ```
    root@test-volume:/# cat /test/test.txt
    Wed Nov 30 17:29:21 UTC 2022
    Wed Nov 30 17:29:21 UTC 2022
    Wed Nov 30 17:29:21 UTC 2022
    Wed Nov 30 17:53:49 UTC 2022
    ```

1. Exit the pod.

    ```sh
    exit
    ```

1. Delete the pod and the vpc

    ```sh
    oc delete pod test-volume
    oc delete pvc test-claim
    ```

Congratulations! You've deployed an app persisting data into a volume.

## Resources

* [Block Storage Data Volume predefined IOPS tiers](https://cloud.ibm.com/docs/vpc?topic=vpc-block-storage-profiles&interface=ui#tiers)
