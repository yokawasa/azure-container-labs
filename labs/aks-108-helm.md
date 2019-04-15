# AKS108: Deploy application to AKS with Helm and Helm Charts

<!-- TOC -->
- [AKS108: Deploy application to AKS with Helm and Helm Charts](#aks108-deploy-application-to-aks-with-helm-and-helm-charts)
  - [Delete the existing Voting app on the cluster](#delete-the-existing-voting-app-on-the-cluster)
  - [Install Helm CLI (only if not installed yet)](#install-helm-cli-only-if-not-installed-yet)
  - [Create a service account (only for RBAC-enabled AKS cluster)](#create-a-service-account-only-for-rbac-enabled-aks-cluster)
  - [Install Helm Chart](#install-helm-chart)
    - [Check default values](#check-default-values)
    - [Verification of the chart](#verification-of-the-chart)
    - [Install Helm chart with your parameter values](#install-helm-chart-with-your-parameter-values)


In this module, you will deploy the voting app (below) to the AKS cluster using Helm and Helm Chart, not applying YAML files one by one.  

What's Helm? - Helm helps you manage Kubernetes applications — Helm Charts helps you define, install, and upgrade even the most complex Kubernetes application. For more detail on Helm/Helm Charts, please visit https://helm.sh/


## Delete the existing Voting app on the cluster

Starting from deleting all resources that has label `app=azure-voting-app`

```
$ kubectl delete svc,deploy,pvc,sc,secrets,cm,ingress -l app=azure-voting-app
```

## Install Helm CLI (only if not installed yet)

You need the helm CLI to develop and manage an applications with Helm. If you're using Azure Cloud Shell, you don't need to install it as it is already there.

```sh
# Mac
$ brew install kubernetes-helm

# Linux (Snap package for Helm)
$ sudo snap install helm

# Windows (Chocolatey package)
$ choco install kubernetes-helm
```
For the detail of Helm installation, please refer to [Installing Helm](https://github.com/helm/helm/blob/master/docs/install.md).


## Create a service account (only for RBAC-enabled AKS cluster)

You need to create a service account and role binding for the Helm `Tiller` service (the Helm server-side component)

```
$ kubectl create -f kubernetes-manifests/rbac/helm.yaml
```

Launch helm with the service account named `tiller` with the following command:

```
$ helm init --service-account tiller
```

This will install `Tiller` service in the `kube-system` namespace. The command output would be like this:

```
$HELM_HOME has been configured at /Users/yoichika/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```

## Install Helm Chart

First of all, change directory to `azure-container-labs/charts`
```sh
$ cd azure-container-labs/charts
$ ls

azure-voting-app
```

### Check default values

Check `azure-voting-app/values.yaml` file and understand default values for the app

```yaml
# Default values for azure-voting-app.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
  
mysql:
  user: dbuser
  password: Password12
  database: azurevote
  rootPassword: Password12

azureVoteFront:
  service:
    name: front
    # service type: LoadBalancer or ClusterIP
    type: LoadBalancer
    externalPort: 80
  deployment:
    replicas: 2
    name: front
    image: yoichikawasaki/azure-vote-front
    imageTag: 1.0.0
    imagePullPolicy: Always
    internalPort: 80
    resources:
      limits:
        cpu: 500m
      requests:
        cpu: 250m

azureVoteBack:
  service:
    name: back
    type: ClusterIP
    externalPort: 3306
  deployment:
    replicas: 1
    name: back
    image: yoichikawasaki/azure-vote-back
    imageTag: 1.0.0
    imagePullPolicy: IfNotPresent
    internalPort: 3306
    resources: {}

persistence:
  enabled: true
  StorageClass: azure-disk-standard
  accessMode: ReadWriteOnce
  size: 1Gi

ingress:
  # Ingress enabled: true or false
  # If enabled, you need to fill host info
  enabled: false
  host: vote.<CLUSTER_SPECIFIC_DNS_ZONE>
```

Now you want to replace default container images  (`yoichikawasaki/azure-vote-front` and  `yoichikawasaki/azure-vote-back`), and default ingress host (`vote.<CLUSTER_SPECIFIC_DNS_ZONE>`) with your values. 

You basically have 2 options - either:
-  adding your values for each parameter in `azure-voting-app/values.yaml` and install the chart
-  or you can giving parameter values on the fly in installing the chart. 

Here let's the latter option.

### Verification of the chart
Before installing a chart, please run the lint command and verify that the chart is well-formed. The `lint` command runs a series of tests to verify that the chart is well-formed.

```sh
$ helm lint azure-voting-app

(output)
==> Linting azure-voting-app
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures
```

### Install Helm chart with your parameter values

```sh
# helm install ./azure-voting-app -n <helm name> --set <key1=value1,key2=value2,...> [--debug]

# case: HTTP Application Routing Ingress controller
$ helm install azure-voting-app \
  -n vote \
  --debug \
  --set \
azureVoteFront.service.type=ClusterIP,\
azureVoteFront.deployment.image=<acrname>.azurecr.io/azure-vote-front,\
azureVoteBack.deployment.image=<acrname>.azurecr.io/azure-vote-back,\
ingress.enabled=true,\
ingress.host=vote.<dnszone>
```
> - Don't add any spaces between values in `--set` parame! For example, `--set a,[space]b` is a bad example
> - For `vote.dnszone`, please add the same CLUSTER_SPECIFIC_DNS_ZONE value that you set in [Setup HTTP Application Routing](ingress-01-http-application-routing.md) to this param


After the installation, get the list of Helm packages

```sh
$ helm ls

NAME            REVISION        UPDATED                         STATUS          CHART                   NAMESPACE
vote            1               Fri Aug 31 14:17:24 2018        DEPLOYED        azure-voting-app-0.1.0  default
```

Get status of `vote` Helm chart

```sh
$ helm status vote

(output)
LAST DEPLOYED: Tue Oct  2 06:42:01 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME                     TYPE    DATA  AGE
azure-voting-app-secret  Opaque  5     4m

==> v1/ConfigMap
NAME                     DATA  AGE
azure-voting-app-config  1     4m

==> v1/StorageClass
NAME                 PROVISIONER               AGE
azure-disk-standard  kubernetes.io/azure-disk  4m

==> v1/PersistentVolumeClaim
NAME                       STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS  AGE
azure-voting-app-pv-claim  Bound   pvc-d4eaee65-c5c2-11e8-9df1-62b806197846  1Gi       RWO           default       4m

==> v1/Service
NAME                    TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)   AGE
azure-voting-app-back   ClusterIP  10.0.23.87    <none>       3306/TCP  4m
azure-voting-app-front  ClusterIP  10.0.201.158  <none>       80/TCP    4m

==> v1beta1/Deployment
NAME                    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
azure-voting-app-back   1        1        1           1          4m
azure-voting-app-front  2        2        2           2          4m

==> v1beta1/Ingress
NAME              HOSTS                                          ADDRESS         PORTS  AGE
azure-voting-app  vote.277b0e61c86b4ea38dbb.japaneast.aksapp.io  40.115.139.244  80     4m

==> v1/Pod(related)
NAME                                     READY  STATUS   RESTARTS  AGE
azure-voting-app-back-7f5cfdffd7-j8vvp   1/1    Running  0         4m
azure-voting-app-front-5895b59496-4h999  1/1    Running  0         4m
azure-voting-app-front-5895b59496-qtg4v  1/1    Running  0         4m

NOTES:
1. Get the Azure Voting App URL to visit by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "component=azure-voting-app-front" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:80
  kubectl port-forward $POD_NAME 80:80
```

Finally, you can access the app with the URL - `http://vote.<CLUSTER_SPECIFIC_DNS_ZONE>`
> [NOTE] it may take over 10 minutes untill you can access the service with the URL after the Helm installation (DNS propagation may take some time)


![](../assets/browse-app-ingress.png)

---
[Top](../README.md) | [Back](aks-107-container-insights.md) | Next (coming soon)
