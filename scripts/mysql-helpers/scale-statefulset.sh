#!/bin/bash

set -e -x

kubectl scale statefulset mysql --replicas=5
