# AKS105: Manual Scale out Pods and Nodes

<!-- TOC -->
- [AKS105: Manual Scale out Pods and Nodes](#aks105-manual-scale-out-pods-and-nodes)
  - [Manual Scale the number of Pods:](#manual-scale-the-number-of-pods)
  - [Manual Scale the number of Nodes:](#manual-scale-the-number-of-nodes)


## Manual Scale the number of Pods:

Check the # of `azure-voting-app-front` pod by running **kubectl get po**:
```sh
$ kubectl get po


NAME                                     READY     STATUS    RESTARTS   AGE
azure-voting-app-back-5fc6b8fdf8-x8zdm   1/1       Running   0          2h
azure-voting-app-front-66fdc889c-4zcfr   1/1       Running   0          2h
azure-voting-app-front-66fdc889c-sdkl4   1/1       Running   0          2h
```

Or you can check by running **kubectl get deploy**:
```sh
$ kubectl get deploy azure-voting-app-front

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-front   2         2         2            2           2h
```

So you have 2 pods for `azure-voting-app-front`. Then, if you want to scale the # of pods to 3, run the following command:
```sh
$ kubectl scale --replicas=3 deploy azure-voting-app-front

deployment "azure-voting-app-front" scaled
```

Check the # of `azure-voting-app-front` pod again:
```
$ kubectl get deploy azure-voting-app-front

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
azure-voting-app-front   3         3         3            3           2h
```

## Manual Scale the number of Nodes:

First of all, check the # of node by running the following command:

```sh
$ kubectl get nodes

NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-40291275-0   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-1   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-2   Ready     agent     21m       v1.11.1
```

You can scale your AKS cluster nodes with the following command:
```
NEW_NODE_COUNT='new node count (e.g., "4")'

az aks scale --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --node-count $NEW_NODE_COUNT
```

Check the # of node again
```
$ kubectl get nodes

NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-40291275-0   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-1   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-2   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-3   Ready     agent     21m       v1.11.1
```


---
[Top](../README.md) | [Back](aks-104-ingress.md) | [Next](aks-106-statefulsets.md)
