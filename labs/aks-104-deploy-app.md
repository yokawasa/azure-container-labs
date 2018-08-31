# Module04: Deploy the application to AKS Cluster

Clone the Github repo via the command line, and change directory:

```sh
git clone https://github.com/yokawasa/azure-container-labs.git
cd azure-container-labs
```

## Create ConfigMap
```sh
$ kubectl apply -f kubernetes-manifests/vote/configmap.yaml

configmap "azure-voting-app-config" created
```

Get ConfigMap list with the following command and confirm that `azure-voting-app-config` configmap resource is in the list
```sh
$ kubectl get configmap

NAME                      DATA      AGE
azure-voting-app-config   1         50s
```

## Create Storage Resource
```sh
$ kubectl apply -f kubernetes-manifests/vote/pvc.yaml

storageclass "azure-disk-standard" created
persistentvolumeclaim "azure-voting-app-pv-claim" created
```

Get PVC info list with the following command and confirm that `azure-voting-app-pv-claim` PVC resource's status is `Bound`
```
$ kubectl get pvc

NAME                        STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
azure-voting-app-pv-claim   Bound     pvc-43382768-9eaa-11e8-b7d0-de454880a5dc   1Gi        RWO            azure-disk-standard   1m
```

## Create Secret Resource

Create Secret resource with the following command
```
$ kubectl apply -f kubernetes-manifests/vote/secret.yaml

secret "azure-voting-app-secret" created
```

### [NOTE] How to check secret info in your Secret resource

Get Secret list with the following command
```sh
$ kubectl get secrets

NAME                      TYPE                                  DATA      AGE
azure-voting-app-secret   Opaque                                5         1m
default-token-stzr8       kubernetes.io/service-account-token   3         11d
```

Get the detail of Secret resource `azure-voting-app-secret`

```sh 
$ kubectl get secrets azure-voting-app-secret -o yaml

apiVersion: v1
data:
  MYSQL_DATABASE: YXp1cmV2b3Rl
  MYSQL_HOST: YXp1cmUtdm90aW5nLWFwcC1iYWNrCg==
  MYSQL_PASSWORD: UGFzc3dvcmQxMg==
  MYSQL_ROOT_PASSWORD: UGFzc3dvcmQxMg==
  MYSQL_USER: ZGJ1c2Vy
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"MYSQL_DATABASE":"YXp1cmV2b3Rl","MYSQL_HOST":"YXp1cmUtdm90ZS1iYWNr","MYSQL_PASSWORD":"UGFzc3dvcmQxMg==","MYSQL_ROOT_PASSWORD":"UGFzc3dvcmQxMg==","MYSQL_USER":"ZGJ1c2Vy"},"kind":"Secret","metadata":{"annotations":{},"labels":{"app":"azure-voting-app"},"name":"azure-voting-app-secret","namespace":"default"},"type":"Opaque"}
  creationTimestamp: 2018-08-13T03:38:02Z
  labels:
    app: azure-voting-app
  name: azure-voting-app-secret
  namespace: default
  resourceVersion: "1275879"
  selfLink: /api/v1/namespaces/default/secrets/azure-voting-app-secret
  uid: 47cd165f-9eaa-11e8-b7d0-de454880a5dc
type: Opaque
```
> Get the output in YAML format with `-o yaml` option
> Secret info is store as Key/Value pair, and each secret value needs to be base64 encoded（For the detail, see [kubenetes.io - Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)）

As each Secret value is base64 encoded, it needs to be base64 decoded to look up its context (ie. MYSQL_PASSWORD）
```sh
$ echo "UGFzc3dvcmQxMg==" | base64 --decode

Password12
```

## Create Deployment
Create Deployment resource with the following command
```
$ kubectl apply -f kubernetes-manifests/vote/deployment.yaml

deployment "azure-voting-app-back" created
deployment "azure-voting-app-front" created
```

Get Pod info list and confirm that all created Pods' status are `Running`

```sh
kubectl get pod -w

NAME                                READY     STATUS              RESTARTS   AGE
azure-voting-app-back-75b9bbc874-8wx6p    0/1       ContainerCreating   0          1m
azure-voting-app-front-86694fdcb4-5jjsm   0/1       ContainerCreating   0          1m
azure-voting-app-front-86694fdcb4-t6pg6   0/1       ContainerCreating   0          1m
azure-voting-app-back-75b9bbc874-8wx6p    1/1       Running   0         1m
azure-voting-app-front-86694fdcb4-5jjsm   1/1       Running   0         2m
azure-voting-app-front-86694fdcb4-t6pg6   1/1       Running   0         2m
```
> Option `-w` can watch for changes after listing/getting the requested objects

Get Deployment info list and confirm that the number of `DESIRED` and `AVAILABLE` is same.
```sh
$ kubectl get deploy

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-back    1         1         1            1           1m
azure-voting-app-front   2         2         2            2           1m
```

## Create Service

Create Service resource with the following command
```sh
$ kubectl apply -f kubernetes-manifests/vote/service.yaml

service "azure-voting-app-back" created
service "azure-voting-app-front" created
```

Get Service info list. Wait until an external IP for `azure-voting-app-front` is assigned in`EXTERNAL-IP` field

```sh
kubectl get svc -w

NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
azure-voting-app-back    ClusterIP      10.0.199.124   <none>        3306/TCP       34s
azure-voting-app-front   LoadBalancer   10.0.45.202    <pending>     80:32125/TCP   33s
kubernetes               ClusterIP      10.0.0.1       <none>        443/TCP        11d
azure-voting-app-front   LoadBalancer   10.0.45.202   40.115.180.143   80:32125/TCP   45s
```
> Option `-w` can watch for changes after listing/getting the requested objects

Access the service with an assigned external IP
```
curl 40.115.180.143    << an assigned external IP
```

NOTE: an external IP can be obtained by using `-o jsonpath` option like this:
```
EXTERNALIP=$(kubectl get svc azure-voting-app-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $EXTERNALIP
```

![](../img/browse-app.png)

---
[Top](toc.md) | [Back](module01.md) | Next
