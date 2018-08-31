# RBAC

## Simple RBAC for accessing Dashboard

RBAC for Dashboard needs to be configured to enjoy full Kubernetes dashbaord capabilities 

Deploy it
```
$ kubectl create -f kubernetes-manifests/rbac/dashboard.yaml
```
Then, access to the dashbaord

```
az aks browse --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

Or alternatively you can access using kubectl
```
$ kubectl proxy
$ open http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/login
```

For more detils of RBAC for Kubernetes dashboard, see [this:https://unofficialism.info/posts/accessing-rbac-enabled-kubernetes-dashboard/]

