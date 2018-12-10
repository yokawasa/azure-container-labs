#!/bin/bash

set -e -x

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
sleep 2
open http://localhost:3000
