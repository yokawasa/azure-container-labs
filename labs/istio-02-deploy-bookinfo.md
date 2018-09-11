# Istio02: Deploy Sample App - BookInfo

## Check if  your environment support automatic sidecar injection

You have 2 ways to inject sidecar: `manual sidecar injection` or `automatic sidecar injection`. 
 Automatic sidecar injection requires that your Kubernetes api-server supports `admissionregistration.k8s.io/v1beta1` or `admissionregistration.k8s.io/v1beta2` APIs. Verify whether your Kubernetes deployment supports these APIs by  executing:

```
$ kubectl api-versions | grep admissionregistration

 admissionregistration.k8s.io/v1alpha1
 admissionregistration.k8s.io/v1beta1
```

If your environment supports these two APIs, then you may use `automatic sidecar injection`. 

## Deploy sample app - Bookinfo
### Option1 - manual sidecar injection.
```
$ kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

service "details" created
deployment "details-v1" created
service "ratings" created
deployment "ratings-v1" created
service "reviews" created
deployment "reviews-v1" created
deployment "reviews-v2" created
deployment "reviews-v3" created
service "productpage" created
deployment "productpage-v1" created
```

### Option2 - automatic  sidecar injection.
If you are using a cluster with automatic sidecar injection enabled, label the default namespace with istio-injection=enabled

```
$ kubectl label namespace default istio-injection=enabled

namespace "default" labeled
```

Then simply deploy the services using kubectl
```
$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

service "details" created
deployment "details-v1" created
service "ratings" created
deployment "ratings-v1" created
service "reviews" created
deployment "reviews-v1" created
deployment "reviews-v2" created
deployment "reviews-v3" created
service "productpage" created
deployment "productpage-v1" created
```

## Confirm all svc and pods are running

Get service lists:
```
$ kubectl get svc

NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
details              ClusterIP      10.0.208.13    <none>         9080/TCP       2m
kubernetes           ClusterIP      10.0.0.1       <none>         443/TCP        13d
party-clippy         ClusterIP      10.0.29.167    <none>         80/TCP         3d
productpage          ClusterIP      10.0.139.249   <none>         9080/TCP       2m
ratings              ClusterIP      10.0.3.187     <none>         9080/TCP       2m
reviews              ClusterIP      10.0.39.59     <none>         9080/TCP       2m
```

Check if all Pods' STATUS are `running`
```
$ kubectl get pods

NAME                                  READY     STATUS    RESTARTS   AGE
details-v1-596775d474-kmf5x           2/2       Running   0          2m
productpage-v1-6c78bf6fb6-4ml55       2/2       Running   0          2m
ratings-v1-6b794b4db6-lfjq8           2/2       Running   0          2m
reviews-v1-7cffb56b4d-6v25n           2/2       Running   0          2m
reviews-v2-869dcbf5c4-rvmhd           2/2       Running   0          2m
reviews-v3-75c98fbc6-78m9k            2/2       Running   0          2m
```


---
[Istio Top](aks-202-istio-top.md)| [Back](istio-01-setup.md) | [Next](istio-03-ingress-gateway.md)