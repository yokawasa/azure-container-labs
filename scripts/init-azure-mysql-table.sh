#!/bin/sh
set -e -x

if [ $# -ne 1 ]
then
    echo "USAGE: $0 <osba-secret-name>"
    exit 1
fi
OSBA_SECRET=$1

user=$(kubectl get secret $OSBA_SECRET -o jsonpath="{.data.username}" | base64 --decode)
password=$(kubectl get secret $OSBA_SECRET -o jsonpath="{.data.password}" | base64 --decode)
host=$(kubectl get secret $OSBA_SECRET -o jsonpath="{.data.host}" | base64 --decode)
db="$(kubectl get secret $OSBA_SECRET -o jsonpath="{.data.database}" | base64 --decode)"
query="DROP TABLE IF EXISTS azurevote; CREATE TABLE azurevote (voteid INT NOT NULL AUTO_INCREMENT,votevalue VARCHAR(45) NULL,PRIMARY KEY (voteid));"
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never --\
    bash -ic "mysql -u $user -h $host -p$password $db -e\"$query\""
