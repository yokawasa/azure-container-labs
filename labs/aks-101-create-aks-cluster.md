# AKS101: Create Azure Kubernetes Service (AKS) Cluster

## 1. Create Resource Group
```sh
$ az group create -g user_akstest -l eastus
```

## 2. Create AKS Cluster
```sh
$ az aks create --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --kubernetes-version 1.11.1 \
    --node-vm-size Standard_D2_v2 \
    --node-count 3 \
    --enable-addons http_application_routing \
    --generate-ssh-keys
```
>- This tutorial assumes that you create the AKS cluster named `user-akscluster` (node count `3`, Kubernetes cluster version `1.11.1`) under the resource group named `user-akstest`
>- If you already have a ssh key generated and you want to use it instead of generating new key, specify your SSH key with --ssh-key-value option instead of --generate-ssh-keys in creating AKS Cluster. Please see azure CLI command reference for az aks create for more details

Run the following command to configure kubectl to connect to your Kubernetes cluster, run the following command:
```
$ az aks get-credentials -g user-akstest -n user-akscluster
```

Finally, check if you can connect to the cluster by running the following command:

```
$ kubectl get nodes

NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-40291275-0   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-1   Ready     agent     21m       v1.11.1
aks-nodepool1-40291275-2   Ready     agent     21m       v1.11.1
```

---
[Top](../README.md) | [Back](aks-100-setup-env.md) | [Next](aks-102-acr.md)
