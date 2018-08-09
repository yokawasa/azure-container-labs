#!/bin/bash

set -e -x

kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
    bash -ic "while sleep 1; do for s in \$(seq 2);do echo -n \"mysql-\$s.mysql\"; mysql -h mysql-\$s.mysql -e 'SHOW SLAVE STATUS\G' | grep Read_Master_Log_Pos;done; done"
