#!/bin/bash

set -e -x

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &
sleep 2
open http://localhost:9090/graph
