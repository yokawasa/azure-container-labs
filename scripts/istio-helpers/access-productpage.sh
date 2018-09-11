#!/bin/bash

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$SECURE_INGRESS_PORT
echo "Accessing to http://${GATEWAY_URL}/productpage ..."
curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage

