#!/bin/bash

set -e -x

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 &
sleep 2
open http://localhost:20001
