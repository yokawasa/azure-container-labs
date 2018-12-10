#!/bin/bash

set -e -x

kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &
sleep 2
open http://localhost:16686
