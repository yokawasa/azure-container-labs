# Istio Sample Project - helloworld

## Deploy Sample Apps, Ingress Gateway, and Destination Rules
```sh
# helloworld v1 & v2 App
kubectl apply -f <(istioctl kube-inject --debug -f helloworld-app.yaml)
# or if automatic injestion is enabled
kubectl apply -f helloworld-app.yaml

# Istio Destination Rules
kubectl apply -f istio-destinationrule.yaml

# Istio Ingress Gateway
kubectl apply -f istio-gateway.yaml
```

Get the URL of the ingress controller
```sh
GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o 'jsonpath={.status.loadBalancer.ingress[0].ip}'):$(kubectl get svc istio-ingressgateway -n istio-system -n istio-system -o 'jsonpath={.spec.ports[0].targetPort}')
echo $GATEWAY_URL
```

## Configure Istio VirtualService to control traffic 

### Route 50% traffic to v1 & 50% to v2 version
```sh
kubectl apply -f istio-virtualservice-even.yaml
```

Access Test: Request to Gateway (Ingest)
```sh
while true; do curl http://$GATEWAY_URL/hello; sleep 1; done

Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v1, instance: helloworld-blue-84c7b5cf84-5rttf
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v1, instance: helloworld-blue-84c7b5cf84-5rttf
Hello version: v1, instance: helloworld-blue-84c7b5cf84-5rttf
```

### Route 10% traffic to v1 & 90% to v2
```sh
kubectl apply -f istio-virtualservice-blue10-green90.yam
```

Access Test: Request to Gateway (Ingest)
```sh
while true; do curl http://$GATEWAY_URL/hello; sleep 1; done

Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v1, instance: helloworld-blue-84c7b5cf84-5rttf
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
..
```

### Route 100% traffic to v2 only when foo in Header is equal to bar
```sh
kubectl apply -f istio-virtualservice-conditional.yam
```

Access Test: Request to Gateway (Ingest)
```sh
while true; do curl -H "foo: bar" http://$GATEWAY_URL/hello; sleep 1; done

Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
Hello version: v2, instance: helloworld-green-6b8b6b674d-b5nbs
...
```

## Delete Projects
Delete all Virtual Services
```sh
$ kubectl get virtualservice

NAME        AGE
bookinfo    1d
helloworld   21m

$ kubectl delete virtualservice helloworld
```

Delete all Destination Rules
```sh
$ kubectl get destinationrule

NAME        AGE
helloworld   48m

$ kubectl delete destinationrule helloworld
```
Delete all Ingress Gateway
```sh
$ kubectl get gateway

NAME                AGE
bookinfo-gateway    1d
helloworld-gateway   49m

$ kubectl delete gateway helloworld-gateway
```

Delete all deployments
```
kubectl delete -f helloworld-v1.yaml
kubectl delete -f helloworld-v2.yaml
```

## Misc Istio Commands - istioctl
Get all proxy status
```sh
$ istioctl proxy-status

Stderr when execute [/usr/local/bin/pilot-discovery request GET /debug/syncz ]: gc 1 @0.011s 9%: 0.026+1.2+1.2 ms clock, 0.053+0.26/0.10/1.0+2.4 ms cpu, 4->4->2 MB, 5 MB goal, 2 P
gc 2 @0.022s 11%: 0.007+1.3+1.2 ms clock, 0.014+0.15/0.36/1.1+2.4 ms cpu, 4->4->2 MB, 5 MB goal, 2 P

PROXY                                                  CDS        LDS        EDS               RDS          PILOT                            VERSION
details-v1-6764bbc7f7-sdc7m.default                    SYNCED     SYNCED     SYNCED (98%)      SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
istio-egressgateway-7cf89fb4f7-g4flm.istio-system      SYNCED     SYNCED     SYNCED (98%)      NOT SENT     istio-pilot-864dc8c497-pmzl2     1.0.2
istio-ingressgateway-6996d566d4-spxkz.istio-system     SYNCED     SYNCED     SYNCED (98%)      SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
productpage-v1-54b8b9f55-gthrr.default                 SYNCED     SYNCED     SYNCED (98%)      SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
ratings-v1-7bc85949-vcnlw.default                      SYNCED     SYNCED     SYNCED (100%)     SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
reviews-v1-fdbf674bb-ddw9w.default                     SYNCED     SYNCED     SYNCED (98%)      SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
reviews-v2-5bdc5877d6-tjgmg.default                    SYNCED     SYNCED     SYNCED (100%)     SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2
reviews-v3-dd846cc78-9lldp.default                     SYNCED     SYNCED     SYNCED (98%)      SYNCED       istio-pilot-864dc8c497-pmzl2     1.0.2

```