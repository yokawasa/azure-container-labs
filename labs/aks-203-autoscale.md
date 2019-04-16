# AKS203: Autoscale (HPA + CA)

<!-- TOC -->
- [AKS203: Autoscale (HPA + CA)](#aks203-autoscale-hpa--ca)
  - [Create VMSS Enabled Cluster](#create-vmss-enabled-cluster)
  - [Deploy sample app to AKS Cluster](#deploy-sample-app-to-aks-cluster)
  - [Autoscale Pods with Horizontal Pod Autoscaler (HPA)](#autoscale-pods-with-horizontal-pod-autoscaler-hpa)
    - [Create HPA](#create-hpa)
    - [Increase Load and check HPA status](#increase-load-and-check-hpa-status)
  - [Autoscale Nodes with Cluster Autoscaler (CA)](#autoscale-nodes-with-cluster-autoscaler-ca)
    - [Enable CA](#enable-ca)
    - [Test Cluster autoscaling](#test-cluster-autoscaling)
  - [Cleanup Resources](#cleanup-resources)

## Create VMSS Enabled Cluster

Prerequisites for AKS clusters that support the cluster autoscaler 
- `Virtual machine scale sets (VMSS)` enabled AKS Cluster
- Kubernetes version `1.12.4 or later`

The scale set support is in preview. To opt in and create clusters that use scale sets, you need to install the `aks-preview Azure CLI extension`. 

Now you create VMSS enabled AKS cluster with `create-aks-cluster-vmss.sh` script. Add your values to parameter sections and run the script:

> scripts/create-aks-cluster-vmss.sh
```sh
################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
SP_CLIENT_SECRET="<Service Principal Secret>"
# Cluster Parameters
VM_SIZE="<VM Size Name for Worker Node>"
SSH_KEY="<SSH Public Key Path>"

################################################################
# Script Start
################################################################
echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Install aks-preview CLI extension"
az extension add --name aks-preview

echo "Register scale set feature provider"
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService

az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.12.6 \
  --node-count 1 \
  --service-principal $SP_CLIENT_ID \
  --client-secret $SP_CLIENT_SECRET \
  --ssh-key-value $SSH_KEY \
  --enable-vmss
```

Once AKS cluster is provisioned, run the following command to configure kubectl to connect to your Kubernetes cluster:
```
az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME
```

Check if you can connect to the cluster by running the following command:

```sh
kubectl get nodes

NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-41800236-vmss000000   Ready    agent   4m4s   v1.12.6
```

## Deploy sample app to AKS Cluster

You deploy the same vote app that you've deployed in [AKS103](aks-103-deploy-app.md) module.

```sh
kubectl apply -f kubernetes-manifests/vote/all-in-one.yaml
```

Once you've deployed the app, check if it's accessible. Please follow the procedure - [Access service in the cluster by port-forward](aks-103-deploy-app.md#access-service-in-the-cluster-by-port-forward)


## Autoscale Pods with Horizontal Pod Autoscaler (HPA)

> [NOTE] For HPA, you don't need enable VMSS for the cluster as [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) is purely implemented as k8s API resource and controller.

The `Horizontal Pod Autoscaler (HPA)` automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization. 

### Create HPA

You create Horizontal Pod Autoscaler that maintains between 2 and 10 replicas of the Pods maintaining an average CPU utilization across all Pods of 50% ( HPA increase and decrease the number of replicas via the deployment to maintain an average CPU utilization across all Pods of 50% )

```sh
# Show deployment and get the name of deployment for front app
 kubectl get deploy
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-back    1         1         1            1           110s
azure-voting-app-front   2         2         2            2           110s

# Create HPA for azure-voting-app-front deployment
kubectl autoscale deployment azure-voting-app-front --cpu-percent=50 --min=2 --max=10

horizontalpodautoscaler.autoscaling/azure-voting-app-front autoscaled

```

You can check HPA with `kubectl get hpa`
```sh
kubectl get hpa azure-voting-app-front
NAME                     REFERENCE                           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
azure-voting-app-front   Deployment/azure-voting-app-front   0%/50%    2         10        2          56s
```

### Increase Load and check HPA status

Now, let's see how the autoscaler reacts to increased load. 

Start a container, and send an infinite loop of queries to the azure-voting-app-front service (please run it in a different terminal):

```sh
kubectl run -it --rm load-generator --image=busybox /bin/sh

# Hit enter for command prompt
while true; do wget -q -O- http://azure-voting-app-front.default.svc.cluster.local; done
```

Run the following command. Within a minute or so, you'll see the higher CPU load and the deployment was resized to 5 replicas

```sh
kubectl get hpa azure-voting-app-front -w

NAME                     REFERENCE                           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
azure-voting-app-front   Deployment/azure-voting-app-front   41%/50%   2         10        2          4m46s
azure-voting-app-front   Deployment/azure-voting-app-front   113%/50%   2         10        2          5m34s
azure-voting-app-front   Deployment/azure-voting-app-front   113%/50%   2         10        4          5m49s
azure-voting-app-front   Deployment/azure-voting-app-front   113%/50%   2         10        5          6m4s
azure-voting-app-front   Deployment/azure-voting-app-front   68%/50%    2         10        5          6m34s
azure-voting-app-front   Deployment/azure-voting-app-front   42%/50%    2         10        5          7m34s
```

## Autoscale Nodes with Cluster Autoscaler (CA)

Prerequisites
- VMSS enabled AKS cluster (Create the cluster with `--enable-vmss`)

### Enable CA

Enable the cluster autoscaler on an existing AKS cluster

```sh
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3
```

> [INFO] You can disable the Cluster autoscaler as well:
> 
> ```sh
> az aks update \
>   --resource-group $RESOURCE_GROUP \
>   --name $CLUSTER_NAME \
>   --disable-cluster-autoscaler
> ```


### Test Cluster autoscaling

You can test the autoscaling by running the deployment of sample app with many replicaset:

```sh
# Check current deployment status
kubectl get deploy azure-voting-app-front

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-front   2         2         2            2           79m

# Manual Scale the number of Pods: 2 -> 10
kubectl scale deploy azure-voting-app-front --replicas=10
```

Open 2 separate teminals like this:
> temrinal 1: watch deployment state
```sh
kubectl get deploy azure-voting-app-front -w

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-front   2/10    10           2           80m
azure-voting-app-front   5/10    10           5           82m
azure-voting-app-front   6/10    10           6           84m
azure-voting-app-front   7/10    10           7           84m
azure-voting-app-front   8/10    10           8           84m
azure-voting-app-front   9/10    10           9           84m
azure-voting-app-front   10/10   10           10          84m
```

> temrinal 2: watch nodes state
```sh
$ kubectl get node -w

NAME                                STATUS   ROLES   AGE    VERSION
aks-nodepool1-41800236-vmss000000   Ready    agent   174m   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready    agent   174m   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready    agent   175m   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready    agent   176m   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready    agent   176m   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready    agent   176m   v1.12.6
aks-nodepool1-41800236-vmss000001   NotReady   agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   NotReady   agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   NotReady   agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   176m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   176m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   177m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   177m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   177m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   <invalid>   v1.12.6
aks-nodepool1-41800236-vmss000000   Ready      agent   177m        v1.12.6
aks-nodepool1-41800236-vmss000001   Ready      agent   3s          v1.12.6
```

As you can see, Cluster Autoscaler increased the number of nodes from 1 to 2 in order to accomodate as many replica sets as the target number of replica sets, 10.

## Cleanup Resources

```sh
az group delete --name $RESOURCE_GROUP
```