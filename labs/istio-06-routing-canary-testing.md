# Istio06: Traffic Control - Request Routing and Canary Testing

## Set default destination rule
Before you can use Istio to control the Bookinfo version routing, you need to define the available versions, called subsets, in destination rules. This defaut rule configure to call reviews service round robin between v1, v2, or v3 When we load the /productpage in the browser multiple times.

```
# Suppose that you did not enable mutual TLS, execute this command:
$ kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

destinationrule "productpage" created
destinationrule "reviews" created
destinationrule "ratings" created
destinationrule "details" created
```
Check if reviews services is called round robin: http://$GATEWAY_URL/productpage

## Configure the default route for all services to V1

In previous section, we have configured to call reviews service round robin between v1, v2, or v3 When we load the /productpage in the browser multiple times.

First of all, let's restrict traffic to just V1 of all the services by seting `VirtualSerice` that will route all traffic to v1 of each microservice.:

```
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

virtualservice "productpage" created
virtualservice "reviews" created
virtualservice "ratings" created
virtualservice "details" created
```

This creates a bunch of `virtualservice` and `destinationrule` entries which route calls to v1 of the services.

To view the applied rule:
```
$ kubectl get virtualservice reviews -o yaml

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
  ...
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
```

(Optional) Also display the corresponding subset definitions: 
```
$ kubectl get destinationrules -o yaml
```

Now when we reload the /productpage several times, we will ONLY be viewing the data from v1 of all the services, which means we will not see any ratings (any stars).



## Canary Testing - Traffic Shifting

### Reset Rules (all traffics to v1)
Before we start the next exercise, lets first restrict all traffic to just V1 of all the services

```
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```
Again, all traffic will be routed to v1 of all the services.

### Canary testing w/50% load

To start canary testing, let's begin by transferring 50% of the traffic from reviews:v1 to reviews:v3 with the following command:

```
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

virtualservice "reviews" configured
```

To confirm the rule was applied:
```
$ kc get virtualservice reviews -o yaml

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
  ...
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50
```

Now, if we reload the /productpage in your browser several times, you should now see red-colored star ratings approximately 50% of the time.


### Shift 100% to v3

When version v3 of the reviews service is considered stable, we can route 100% of the traffic to reviews:v3:

```
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-v3.yaml
```

To confirm the rule was applied:
```
$ kubectl get virtualservice reviews -o yaml

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
  ...
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v3
```

Now, if we reload the /productpage in your browser several times, you should now see red-colored star ratings 100% of the time.


---
[Istio Top](aks-202-istio-top.md)| [Back](istio-05-distributed-tracing.md) 
