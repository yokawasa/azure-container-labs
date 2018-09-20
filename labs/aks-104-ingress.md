# Module AKS104: Ingress Controller


## Setup HTTP Application Routing

- https://docs.microsoft.com/ja-jp/azure/aks/http-application-routing
- 
type change from LoadBalancer -> ClusterIP
```sh
vi kubernetes-manifests/vote/service.yaml

  # type: LoadBalancer
  type: ClusterIP
```

or you can directory edit like this and save
```
kubectl edit svc azure-vote-front
```


Re-deploy it using `kubectl apply`

```
$ kubectl apply -f kubernetes-manifests/vote/service.yaml

service "azure-vote-back" created
service "azure-vote-front" created
```

Check if `azure-vote-front` no longer have `EXTERNAL-IP` but only have `CLUSTER-IP`

```sh
$kubectl get svc -w

NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
azure-vote-back    ClusterIP   10.0.155.155   <none>        3306/TCP   2m
azure-vote-front   ClusterIP   10.0.118.224   <none>        80/TCP     2m
kubernetes         ClusterIP   10.0.0.1       <none>        443/TCP    10d
```

Create ingress

```sh
$ kubectl delete -f kubernetes-manifests/vote/ingress.yaml
```

Check if ...
```sh
$ kubectl get ingress -w

NAME           HOSTS                                                   ADDRESS   PORTS     AGE
azure-vote     vote.486f848139314d26aeef.japaneast.aksapp.io                     80        1m
```


## (Optional) Setup NGINX Ingress Controller 
- https://docs.microsoft.com/ja-jp/azure/aks/ingress-basic

## (Optional) Setup Application Gateway Ingress Controller
- https://github.com/Azure/application-gateway-kubernetes-ingress


---
[Top](../README.md) | [Back](aks-103-deploy-app.md) | [Next](aks-105-scaleout.md)
