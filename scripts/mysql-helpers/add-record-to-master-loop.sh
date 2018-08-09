#!/bin/bash
set -e -x

kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --\
  bash -ic "while sleep 1;do mysql -h mysql-0.mysql -e \"INSERT INTO test.messages VALUES ('hello');\";done"
