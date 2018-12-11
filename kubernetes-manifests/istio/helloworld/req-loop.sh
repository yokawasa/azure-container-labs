#!/bin/sh

GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o 'jsonpath={.status.loadBalancer.ingress[0].ip}'):$(kubectl get svc istio-ingressgateway -n istio-system -n istio-system -o 'jsonpath={.spec.ports[0].targetPort}')

while true;
do
    curl http://$GATEWAY_URL/hello
    #curl -H "foo: bar" http://$GATEWAY_URL/hello
    sleep 1
done

