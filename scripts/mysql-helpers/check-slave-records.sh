#!/bin/bash

set -e -x

kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never --\
  mysql -h mysql-read -e "SELECT * FROM test.messages"
