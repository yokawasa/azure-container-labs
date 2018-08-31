# Helm



Starting from deleting all resources that has label `app=azure-voting-app`
```
$ kubectl delete svc,deploy,pvc,sc,secrets,cm,ingress -l app=azure-voting-app
```


## RBAC

Deploy it
```
$ kubectl create -f kubernetes-manifests/rbac/helm.yaml
```

Launch helm with the service account

```
$ helm init --service-account helm --upgrade


$HELM_HOME has been configured at /Users/yoichika/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```



## Install

change directory to `azure-container-labs/charts`
```
cd azure-container-labs/charts
```
Then install help chart
```sh
# $ helm install ./azure-voting-app --debug
# $ helm install ./azure-voting-app -n <helm name> --debug
$ helm install ./azure-voting-app -n vote --debug 
```

Check status
```sh
$ helm ls
NAME            REVISION        UPDATED                         STATUS          CHART                   NAMESPACE
vote            1               Fri Aug 31 14:17:24 2018        DEPLOYED        azure-voting-app-0.1.0  default

$ helm status vote

LAST DEPLOYED: Fri Aug 31 14:17:24 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                                    READY  STATUS   RESTARTS  AGE
azure-voting-app-back-8b4899854-4q5bd   1/1    Running  0         2m
azure-voting-app-front-8587889df-7x74j  1/1    Running  0         2m
azure-voting-app-front-8587889df-vknxv  1/1    Running  0         2m

==> v1/Secret
NAME                     TYPE    DATA  AGE
azure-voting-app-secret  Opaque  5     2m

==> v1/ConfigMap
NAME                     DATA  AGE
azure-voting-app-config  1     2m

==> v1/StorageClass
NAME                 PROVISIONER               AGE
azure-disk-standard  kubernetes.io/azure-disk  2m

==> v1/PersistentVolumeClaim
NAME                       STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS  AGE
azure-voting-app-pv-claim  Bound   pvc-25460fe1-acdd-11e8-9b3c-a697f42fbc58  1Gi       RWO           default       2m

==> v1/Service
NAME                    TYPE          CLUSTER-IP   EXTERNAL-IP     PORT(S)       AGE
azure-voting-app-back   ClusterIP     10.0.209.41  <none>          3306/TCP      2m
azure-voting-app-front  LoadBalancer  10.0.195.51  23.100.100.104  80:31612/TCP  2m

==> v1beta1/Deployment
NAME                    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
azure-voting-app-back   1        1        1           1          2m
azure-voting-app-front  2        2        2           2          2m


NOTES:
1. Get the Azure Voting App URL to visit by running these commands in the same shell:
  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        You can watch the status of by running 'kubectl get svc --namespace default -w azure-voting-app-front'
  export SERVICE_IP=$(kubectl get svc --namespace default azure-voting-app-front --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
  echo http://$SERVICE_IP:80
```

## delete package
```sh
$ helm del vote

release "vote" deleted
```

## Helm Install with parameters

```
$ helm install ./azure-voting-app -n vote-dev --set azureVoteFront.service.type=ClusterIP,ingress.enabled=true,ingress.host=vote.04929addf0a547ef8320.japaneast.aksapp.io --debug


NAME:   unsung-dog
REVISION: 1
RELEASED: Mon Aug 13 10:23:43 2018
CHART: azure-voting-app-0.1.0
USER-SUPPLIED VALUES:
azureVoteFront:
  service:
    type: ClusterIP
ingress:
  enabled: true
  host: vote.486f848139314d26aeef.japaneast.aksapp.io

COMPUTED VALUES:
azureVoteBack:
  deployment:
    image: yoichikawasaki/azure-vote-back
    imagePullPolicy: IfNotPresent
    imageTag: 1.0.0
    internalPort: 3306
    name: back
    replicas: 1
    resources: {}
  service:
    externalPort: 3306
    name: back
    type: ClusterIP
azureVoteFront:
  deployment:
    image: yoichikawasaki/azure-vote-front
    imagePullPolicy: Always
    imageTag: 1.0.0
    internalPort: 80
    name: front
    replicas: 2
    resources:
      limits:
        cpu: 500m
      requests:
        cpu: 250m
  service:
    externalPort: 80
    name: front
    type: ClusterIP
ingress:
  enabled: true
  host: vote.486f848139314d26aeef.japaneast.aksapp.io
mysql:
  database: azurevote
  password: Password12
  rootPassword: Password12
  user: dbuser
persistence:
  StorageClass: azure-disk-standard
  accessMode: ReadWriteOnce
  enabled: true
  size: 1Gi

HOOKS:
MANIFEST:

---
# Source: azure-voting-app/templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: azure-voting-app-secret
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
type: Opaque
data:
  MYSQL_USER: "ZGJ1c2Vy"
  MYSQL_PASSWORD: "UGFzc3dvcmQxMg=="
  MYSQL_DATABASE: "YXp1cmV2b3Rl"
  MYSQL_HOST: "YXp1cmUtdm90aW5nLWFwcC1iYWNr"
  MYSQL_ROOT_PASSWORD: "UGFzc3dvcmQxMg=="
---
# Source: azure-voting-app/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: azure-voting-app-config
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
data:
  config_file.cfg: |
    # UI Configurations
    TITLE = 'Azure Voting App'
    VOTE1VALUE = 'Beer'
    VOTE2VALUE = 'Wine'
    SHOWHOST = 'false'
---
# Source: azure-voting-app/templates/storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-standard
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
provisioner: kubernetes.io/azure-disk
parameters:
  kind: Managed
  storageaccounttype: Standard_LRS
---
# Source: azure-voting-app/templates/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-voting-app-pv-claim
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: "1Gi"
---
# Source: azure-voting-app/templates/azure-vote-back-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: azure-voting-app-back
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
spec:
  type: ClusterIP
  ports:
    - port: 3306
      name: mysql
  selector:
    app: azure-voting-app
    component: azure-voting-app-back
    release: unsung-dog
---
# Source: azure-voting-app/templates/azure-vote-front-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: azure-voting-app-front
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
spec:
  type: ClusterIP
  ports:
    - port: 80
  selector:
    app: azure-voting-app
    component: azure-voting-app-front
    release: unsung-dog
---
# Source: azure-voting-app/templates/azure-vote-back-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: azure-voting-app-back
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
    component: azure-voting-app-back
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: azure-voting-app
        heritage: "Tiller"
        release: "unsung-dog"
        chart: azure-voting-app-0.1.0
        component: azure-voting-app-back
    spec:
      containers:
      - name: azure-voting-app-back
        image: "yoichikawasaki/azure-vote-back:1.0.0"
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3306
          name: mysql
        args:
          - --ignore-db-dir=lost+found
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_DATABASE
        resources:
          {}

      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: azure-voting-app-pv-claim
---
# Source: azure-voting-app/templates/azure-vote-front-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: azure-voting-app-front
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
    component: azure-voting-app-front
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: azure-voting-app
        heritage: "Tiller"
        release: "unsung-dog"
        chart: azure-voting-app-0.1.0
        component: azure-voting-app-front
    spec:
      containers:
      - name: azure-voting-app-front
        image: "yoichikawasaki/azure-vote-front:1.0.0"
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_DATABASE
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              name: azure-voting-app-secret
              key: MYSQL_HOST
        - name: FLASK_CONFIG_FILE_PATH
          value: /etc/config/config_file.cfg
        volumeMounts:
        - name: config-map
          mountPath: /etc/config
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 250m

      volumes:
      - name: config-map
        configMap:
          name: azure-voting-app-config
---
# Source: azure-voting-app/templates/ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: azure-voting-app
  labels:
    app: azure-voting-app
    heritage: "Tiller"
    release: "unsung-dog"
    chart: azure-voting-app-0.1.0
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
  - host: vote.486f848139314d26aeef.japaneast.aksapp.io
    http:
      paths:
      - backend:
          serviceName: azure-voting-app-front
          servicePort: 80
        path: /
LAST DEPLOYED: Mon Aug 13 10:23:43 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                    TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)   AGE
azure-voting-app-back   ClusterIP  10.0.37.237   <none>       3306/TCP  1s
azure-voting-app-front  ClusterIP  10.0.156.233  <none>       80/TCP    1s

==> v1beta1/Deployment
NAME                    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
azure-voting-app-back   1        1        1           0          1s
azure-voting-app-front  2        2        2           0          1s

==> v1beta1/Ingress
NAME              HOSTS                                          ADDRESS  PORTS  AGE
azure-voting-app  vote.486f848139314d26aeef.japaneast.aksapp.io  80       1s

==> v1/Pod(related)
NAME                                    READY  STATUS             RESTARTS  AGE
azure-voting-app-back-5dc97c756c-l9slq  0/1    Pending            0         0s
azure-voting-app-front-799897ccd-gr47d  0/1    ContainerCreating  0         0s
azure-voting-app-front-799897ccd-kjlpp  0/1    ContainerCreating  0         0s

==> v1/Secret
NAME                     TYPE    DATA  AGE
azure-voting-app-secret  Opaque  5     1s

==> v1/ConfigMap
NAME                     DATA  AGE
azure-voting-app-config  1     1s

==> v1/StorageClass
NAME                 PROVISIONER               AGE
azure-disk-standard  kubernetes.io/azure-disk  1s

==> v1/PersistentVolumeClaim
NAME                       STATUS   VOLUME   CAPACITY  ACCESS MODES  STORAGECLASS  AGE
azure-voting-app-pv-claim  Pending  default  1s


NOTES:
1. Get the Azure Voting App URL to visit by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "component=azure-voting-app-front" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:80
  kubectl port-forward $POD_NAME 80:80

```



## HOW TO USE HELP commands

```
helm install https://myhelmrepo001.blob.core.windows.net/helmrepo/azure-voting-app-0.1.0.tgz -n vote-dev

helm install https://myhelmrepo001.blob.core.windows.net/helmrepo/azure-voting-app-0.1.0.tgz -n vote-dev --set azureVoteFront.service.type=ClusterIP,ingress.enabled=true,ingress.host=vote.486f848139314d26aeef.japaneast.aksapp.io,azureVoteFront.deployment.image=yoichika.azurecr.io/azure-voting-app-front,azureVoteFront.deployment.imageTag=latest
```



