# Manage AKS Cluster using azure-cli

## Browse Kubernete dashboard with AKS

You can browse Kubernete dashbboard for your AKS cluster with the following command:
```
RESOURCE_GROUP='your resource group (e.g., "RG-aks")'
CLUSTER_NAME='your AKS cluster name (e.g., "myAKSCluster")'

az aks browse --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```
![](../assets/k8s-dashboard.png)

If you're using RBAC enabled kubernetes cluster, you need to configure Service Account and RoleBinding in order to make Dashbaord work.
```sh
# Here is a way to give full privilege (role: cluster-admin) to the Dashboard’s Service Account kubernetes-dashboard
$ cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
EOF
```

If you want to configure more granular privilege to the Dashboard's service account instead of giving full privilege(role: cluster-admin), please follow "Option 1: Access to Dashboard with your Service Account" in [this article](https://unofficialism.info/posts/accessing-rbac-enabled-kubernetes-dashboard/). 

In addition, please see [Kubernetes dashboard with Azure Container Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard) to know about basic dashboard operations.



## Get available Kubernetes version in your region
The following command return the versions available to create / upgrade:
```
LOCATION='your location (e.g., "eastus")'

az aks get-versions --location $LOCATION --output table
```

Sample Output:
```
KubernetesVersion    Upgrades
-------------------  -------------------------------------------------------------------------
1.9.6                None available
1.9.2                1.9.6
1.9.1                1.9.2, 1.9.6
1.8.11               1.9.1, 1.9.2, 1.9.6
1.8.10               1.8.11, 1.9.1, 1.9.2, 1.9.6
1.8.7                1.8.10, 1.8.11, 1.9.1, 1.9.2, 1.9.6
1.8.6                1.8.7, 1.8.10, 1.8.11, 1.9.1, 1.9.2, 1.9.6
1.8.2                1.8.6, 1.8.7, 1.8.10, 1.8.11, 1.9.1, 1.9.2, 1.9.6
1.8.1                1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11, 1.9.1, 1.9.2, 1.9.6
1.7.16               1.8.1, 1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11
1.7.15               1.7.16, 1.8.1, 1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11
1.7.12               1.7.15, 1.7.16, 1.8.1, 1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11
1.7.9                1.7.12, 1.7.15, 1.7.16, 1.8.1, 1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11
1.7.7                1.7.9, 1.7.12, 1.7.15, 1.7.16, 1.8.1, 1.8.2, 1.8.6, 1.8.7, 1.8.10, 1.8.11
```

## Upgrde AKS Cluster

Check which Kubernetes releases are available for upgrade for your AKS cluster:
```
RESOURCE_GROUP='your resource group (e.g., "RG-aks")'
CLUSTER_NAME='your AKS cluster name (e.g., "myAKSCluster")'

az aks get-upgrades --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --output table
```
Sample Output:
```
Name     ResourceGroup    MasterVersion    NodePoolVersion    Upgrades
-------  ---------------  ---------------  -----------------  -----------------------------------------
default  RG-aks           1.7.7            1.7.7              1.7.9, 1.7.12, 1.8.1, 1.8.2, 1.8.6, 1.8.7
```

Run the following command to upgrade your cluster to new kubernetes version:

```
RESOURCE_GROUP='your resource group (e.g., "RG-aks")'
CLUSTER_NAME='your AKS cluster name (e.g., "myAKSCluster")'
NEW_VERSION='new kubernetes version (e.g., "1,8.6")'

az aks upgrade --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --kubernetes-version $NEW_VERSION
```

See also [Upgrade an Azure Container Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster) to lean more about the configuration


## Scale AKS Cluster Nodes

You can scale your AKS cluster nodes with the following command:
```
RESOURCE_GROUP='your resource group (e.g., "RG-aks")'
CLUSTER_NAME='your AKS cluster name (e.g., "myAKSCluster")'
NEW_NODE_COUNT='new node count (e.g., "2")'

az aks scale --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --node-count $NEW_NODE_COUNT
```

Check the list of nodes with the kubectl:
```
$ kubectl get nodes

(SAMPLE OUTPUT)
NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-17576119-0   Ready     agent     2h        v1.7.7
aks-nodepool1-17576119-1   Ready     agent     1m        v1.7.7
```

See also [Scale an Azure Container Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/scale-cluster) to lean more about the configuration

---
[Top](../README.md)