#!/bin/bash

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$SECURE_INGRESS_PORT
echo "Generate load on http://${GATEWAY_URL}/productpage ..."

docker run istio/fortio load -t 5m -qps 5 http://${GATEWAY_URL}/productpage

